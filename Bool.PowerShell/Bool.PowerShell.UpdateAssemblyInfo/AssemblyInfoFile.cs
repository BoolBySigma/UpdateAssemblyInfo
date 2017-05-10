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
        private static readonly Regex AssemblyAttributeParser = new Regex(@"^(?<start>\s*[\[<]<?\s*[Aa]ssembly\s*:\s*)(?<longname>(?<shortname>\w+?)(Attribute)?)(?<middle>\s*\(\s*""?)(?<value>.*?)(?<end>""?\s*\)\s*>?[>\]])", RegexOptions.Compiled);

        // parser for line comment in C#, VB.Net and F#
        private static readonly Regex LineCommentParser = new Regex(@"^\s*(//|')", RegexOptions.Compiled);

        // parser for multiline comment start in C# and F#
        private static readonly Regex MultilineCommentStartParser = new Regex(@"^\s*(/\*|\(\*)", RegexOptions.Compiled);

        // parser for multiline comment end in C# and F#
        private static readonly Regex MultilineCommentEndParser = new Regex(@".*?(\*/|\*\))", RegexOptions.Compiled);

        // raw file lines
        private readonly IList<string> lines = new List<string>();

        // assembly attributes
        private readonly IDictionary<string, MatchResult> attributes = new Dictionary<string, MatchResult>();

        private bool? ensureAttribute = false;
   
        // programming language
        private readonly Language language;

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
        public string this[string attributeName]
        {
            get
            {
                if (!this.attributes.ContainsKey(attributeName))
                {
                    if (this.ensureAttribute.HasValue && this.ensureAttribute.Value)
                    {
                        return this.CreateAttribute(attributeName).Value;
                    }

                    return null;
                }

                return this.attributes[attributeName].Value;
            }

            set
            {
                if (!this.attributes.TryGetValue(attributeName, out MatchResult r))
                {
                    if (this.ensureAttribute.HasValue && this.ensureAttribute.Value)
                    {
                        r = this.CreateAttribute(attributeName, value);
                    }
                    else
                    {
                        return;
                    }
                }
                r.Value = value;
                this.lines[r.LineNumber] = string.Format(r.Format, value);
            }
        }

        private string AttributePrefix
        {
            get
            {
                switch (this.language)
                {
                    case Language.Cs:
                    {
                        return "[";
                    }
                    case Language.Vb:
                    {
                        return "<";
                    }
                    default:
                    {
                        return "[<";
                    }
                }
            }
        }

        private string AttributeSuffix
        {
            get
            {
                switch (this.language)
                {
                    case Language.Cs:
                    {
                        return "]";
                        }
                    case Language.Vb:
                    {
                        return ">";
                    }
                    default:
                    {
                        return ">]";
                    }
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
        public AssemblyInfoFile(string path, bool? ensureAttribute)
        {
            this.ensureAttribute = ensureAttribute;
            this.language = this.DetermineFileLanguage(path);

            using (var sr = File.OpenText(path))
            {
                var line = default(string);
                var lineNumber = 0;
                var isComment = false;

                // read lines one by one
                while ((line = sr.ReadLine()) != null)
                {
                    this.lines.Add(line);

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

                        if (!this.attributes.ContainsKey(attributeName))
                        {
                            this.attributes[attributeName] = new MatchResult { Format = matches.Groups["start"].Value + matches.Groups["longname"].Value + matches.Groups["middle"].Value + "{0}" + matches.Groups["end"].Value, LineNumber = lineNumber, Value = matches.Groups["value"].Value };
                        }
                    }

                    ++lineNumber;
                }
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
            foreach (var line in this.lines)
            {
                writer.WriteLine(line);
            }
        }

        public string BooleanToString(bool value)
        {
            switch (language)
            {
                case Language.Cs:
                case Language.Fs:
                {
                    return value.ToString().ToLower();
                    }
                case Language.Vb:
                {
                    return value.ToString();
                    }
                default:
                {
                    throw new Exception("Unsupported language");
                }
            }
        }

        private string CreateAttributeFormat(string attributeName, string attributeValue)
        {
            var stringFormat = this.AttributePrefix + "assembly: " + attributeName + "(\"{0}\")" + this.AttributeSuffix;
            if (string.IsNullOrEmpty(attributeValue))
            {
                return stringFormat;
            }

            if (bool.TryParse(attributeValue, out bool isBoolean))
            {
                return this.AttributePrefix + "assembly: " + attributeName + "({0})" + this.AttributeSuffix;
            }

            return stringFormat;
        }

        private string CreateAttributeValue(string attributeName)
        {
            switch (attributeName)
            {
                case "AssemblyVersion":
                case "AssemblyFileVersion":
                {
                    return "1.0.0.0";
                }
                default:
                {
                    return string.Empty;
                }
            }
        }

        private MatchResult CreateAttribute(string attributeName)
        {
            return this.CreateAttribute(attributeName, string.Empty);
        }

        private MatchResult CreateAttribute(string attributeName, string attributeValue)
        {
            if (string.IsNullOrEmpty(attributeValue))
            {
                attributeValue = this.CreateAttributeValue(attributeName);
            }

            this.lines.Add(attributeValue);
            var lineNumber = this.lines.Count - 1;

            this.attributes[attributeName] = new MatchResult
            {
                Format = this.CreateAttributeFormat(attributeName, attributeValue),
                LineNumber = lineNumber,
                Value = attributeValue
            };

            return this.attributes[attributeName];
        }

        private Language DetermineFileLanguage(string path)
        {
            var extension = Path.GetExtension(path);
            switch (extension)
            {
                case ".fs":
                {
                    return Language.Fs;
                }
                case ".vb":
                {
                    return Language.Vb;
                }
                case ".cs":
                {
                    return Language.Cs;
                }
                default:
                {
                    throw new ArgumentOutOfRangeException("File extension " + extension + "is not supported");
                }
            }
        }
    }
}