namespace Bool.PowerShell.UpdateAssemblyInfo
{
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Text.RegularExpressions;

    /// <summary>
    ///     Represents a parsed AssemblyInfo file.
    /// </summary>
    /// <remarks>
    ///     To correctly parse multiline comments, it must start at the beginning of a line.
    /// </remarks>
    internal class AssemblyInfoFile
    {
        // parser for assembly attributes in C#, VB.Net and F#
        private static readonly Regex AssemblyAttributeParser =
            new Regex(
                @"^(?<start>\s*[\[<]<?\s*[Aa]ssembly\s*:\s*)(?<longname>(?<shortname>\w+?)(Attribute)?)(?<middle>\s*\(\s*""?)(?<value>.*?)(?<end>""?\s*\)\s*>?[>\]])",
                RegexOptions.Compiled);

        // parser for line comment in C#, VB.Net and F#
        private static readonly Regex LineCommentParser = new Regex(@"^\s*(//|')", RegexOptions.Compiled);

        // parser for multiline comment start in C# and F#
        private static readonly Regex MultilineCommentStartParser = new Regex(@"^\s*(/\*|\(\*)", RegexOptions.Compiled);

        // parser for multiline comment end in C# and F#
        private static readonly Regex MultilineCommentEndParser = new Regex(@".*?(\*/|\*\))", RegexOptions.Compiled);

        // raw file lines
        private readonly IList<object> _lines = new List<object>();

        // assembly attributes
        private readonly IDictionary<string, AttributeLine> _attributes = new Dictionary<string, AttributeLine>();

        private bool? _ensureAttribute;
        
        private readonly Language _language;

        private readonly UpdateAssemblyInfo _cmdlet;

        /// <summary>
        ///     Gets or sets the attribute value.
        /// </summary>
        /// <param name="attributeName">
        ///     The attribute name.
        /// </param>
        /// <value>
        ///     The attribute value. If the attribute is not declared returns <see langword="null" />.
        /// </value>
        /// <exception cref="ArgumentOutOfRangeException">
        ///     The attribute <paramref name="attributeName" /> is not declared in the parsed file and cannot be set.
        /// </exception>
        /// <returns>string</returns>
        public object this[string attributeName]
        {
            get
            {
                if (!_attributes.ContainsKey(attributeName))
                {
                    if (_ensureAttribute.HasValue && _ensureAttribute.Value)
                        return CreateAttribute(attributeName).Value;

                    return null;
                }

                return _attributes[attributeName].Value;
            }

            set
            {
                if (!_attributes.TryGetValue(attributeName, out AttributeLine r))
                {
                    if (_ensureAttribute.HasValue && _ensureAttribute.Value)
                        r = CreateAttribute(attributeName);
                    else
                        return;
                }

                if (value is bool)
                {
                    r.Value = BooleanToString(value);
                    r.Format = CreateAttributeFormat(attributeName, value);
                }
                else
                    r.Value = value;

                _lines[r.LineNumber] = string.Format(r.Format, r.Value);
            }
        }

        private string AttributePrefix
        {
            get
            {
                switch (_language)
                {
                    case Language.Cs:
                        return "[";
                    case Language.Vb:
                        return "<";
                    default:
                        return "[<";
                }
            }
        }

        private string AttributeSuffix
        {
            get
            {
                switch (_language)
                {
                    case Language.Cs:
                        return "]";
                    case Language.Vb:
                        return ">";
                    default:
                        return ">]";
                }
            }
        }

        /// <summary>
        ///     Initializes a new instance of the <see cref="AssemblyInfoFile" /> class with the specified AssemblyInfo file.
        /// </summary>
        /// <param name="path">
        ///     The AssemblyInfo file to parse.
        /// </param>
        /// <param name="ensureAttribute"></param>
        public AssemblyInfoFile(UpdateAssemblyInfo cmdlet, string path, bool? ensureAttribute)
        {
            _cmdlet = cmdlet;
            _cmdlet.WriteDebug("AssemblyInfoFile");
            _cmdlet.WriteDebug("path: " + path);
            _ensureAttribute = ensureAttribute;
            _cmdlet.WriteDebug("ensureAttribute: " + ensureAttribute);
            _language = DetermineFileLanguage(path);

            using (var sr = File.OpenText(path))
            {
                string line;
                var lineNumber = 0;
                var isComment = false;
                
                _cmdlet.WriteDebug("file begin");
                while ((line = sr.ReadLine()) != null)
                {
                    _cmdlet.WriteDebug(line);
                    _lines.Add(line);

                    if (LineCommentParser.IsMatch(line))
                    {
                        // line comment
                        ++lineNumber;

                        continue;
                    }

                    if (MultilineCommentStartParser.IsMatch(line))
                    {
                        // multiline comment starts
                        ++lineNumber;
                        isComment = true;

                        continue;
                    }

                    if (MultilineCommentEndParser.IsMatch(line) && isComment)
                    {
                        // multiline comment ends
                        ++lineNumber;
                        isComment = false;

                        continue;
                    }

                    if (isComment)
                    {
                        // inside multiline comment
                        ++lineNumber;

                        continue;
                    }

                    var matches = AssemblyAttributeParser.Match(line);
                    if (matches.Success)
                    {
                        // line contains assembly attribute, save result
                        var attributeName = matches.Groups["shortname"].Value;

                        if (!_attributes.ContainsKey(attributeName))
                        {
                            _attributes[attributeName] = new AttributeLine
                            {
                                Format = matches.Groups["start"].Value + matches.Groups["longname"].Value +
                                         matches.Groups["middle"].Value + "{0}" + matches.Groups["end"].Value,
                                LineNumber = lineNumber,
                                Value = matches.Groups["value"].Value
                            };
                        }
                    }

                    ++lineNumber;
                }

                _cmdlet.WriteDebug("file end");
            }
        }

        /// <summary>
        ///     Writes the updated AssemblyInfo file to the specified <see cref="TextWriter" />.
        /// </summary>
        /// <param name="writer">
        ///     The <see cref="TextWriter" /> to write to.
        /// </param>
        public void Write(TextWriter writer)
        {
            _cmdlet.WriteDebug("Write");
            _cmdlet.WriteDebug("file begin");
            foreach (var line in _lines)
            {
                _cmdlet.WriteDebug(line.ToString());
                writer.WriteLine(line);
            }
            _cmdlet.WriteDebug("file end");
        }

        private string BooleanToString(object value)
        {
            _cmdlet.WriteDebug("BooleanToString");
            _cmdlet.WriteDebug($"value: {value}");
            switch (_language)
            {
                case Language.Cs:
                case Language.Fs:
                    return value.ToString().ToLower();
                case Language.Vb:
                    return value.ToString();
                default:
                    throw new Exception("Unsupported language");
            }
        }

        private string CreateAttributeFormat(string attributeName, object attributeValue)
        {
            _cmdlet.WriteDebug("CreateAttributeFormat");
            if (attributeValue is bool)
            {
                _cmdlet.WriteDebug("attribute value is boolean");
                return $"{AttributePrefix}assembly: {attributeName}({{0}}){AttributeSuffix}";
            }

            return $"{AttributePrefix}assembly: {attributeName}(\"{{0}}\"){AttributeSuffix}";
        }

        private object CreateAttributeValue(string attributeName)
        {
            _cmdlet.WriteDebug("CreateAttributeValue");
            _cmdlet.WriteDebug($"attributeName: {attributeName}");
            switch (attributeName)
            {
                case "AssemblyVersion":
                case "AssemblyFileVersion":
                    return "1.0.0.0";
                default:
                    return string.Empty;
            }
        }

        private AttributeLine CreateAttribute(string attributeName, object attributeValue = null)
        {
            _cmdlet.WriteDebug("CreateAttribute");
            _cmdlet.WriteDebug($"attributeName: {attributeName}");
            _cmdlet.WriteDebug($"attributeValue: {attributeValue}");
            if (attributeValue == null)
            {
                _cmdlet.WriteDebug("no attribute value");
                attributeValue = CreateAttributeValue(attributeName);
            }

            _lines.Add(attributeValue);
            var lineNumber = _lines.Count - 1;

            var attributeLine = new AttributeLine
            {
                Format = CreateAttributeFormat(attributeName, attributeValue),
                LineNumber = lineNumber,
                Value = attributeValue
            };
            _cmdlet.WriteDebug($"attributeLine.Format: {attributeLine.Format}");
            _cmdlet.WriteDebug($"attributeLine.LineNumber: {attributeLine.LineNumber}");
            _cmdlet.WriteDebug($"attributeLine.Value: {attributeLine.Value}");

            _attributes[attributeName] = attributeLine;

            return _attributes[attributeName];
        }

        private Language DetermineFileLanguage(string path)
        {
            _cmdlet.WriteDebug("DetermineLanguage");
            _cmdlet.WriteDebug($"path: {path}");
            var extension = Path.GetExtension(path);
            _cmdlet.WriteDebug($"extension: {extension}");
            switch (extension)
            {
                case ".fs":
                    return Language.Fs;
                case ".vb":
                    return Language.Vb;
                case ".cs":
                    return Language.Cs;
                default:
                    throw new ArgumentOutOfRangeException("File extension " + extension + "is not supported");
            }
        }
    }
}