namespace Bool.PowerShell.UpdateAssemblyInfo
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Text.RegularExpressions;

    public class AssemblyInfoUpdater
    {
        #region Fields

        // token parser.
        private static readonly Regex TokenParser = new Regex(@"\$\((?<token>[^:\)]*)(:(?<param>[^\)]+))?\)",
            RegexOptions.Compiled | RegexOptions.IgnoreCase);

        // version parser.
        private static readonly Regex VersionParser = new Regex(@"\d+\.\d+\.\d+\.\d+", RegexOptions.Compiled);

        // AssemblyInfo file access helper.
        private AssemblyInfoFile file;

        // token values.
        private IDictionary<string, Func<string, string>> tokenEvaluators;

        #endregion

        #region Properties

        /// <summary>
        ///     Sets the AssemblyInfo files to update.
        /// </summary>
        /// <remarks>
        ///     This property is <b>required.</b>
        /// </remarks>
        [Description("Specify the AssemblyInfo files path.")]
        public IEnumerable<string> Files { get; set; }

        /// <summary>
        ///     Sets the assembly version.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(current)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(increment)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly version. (null to disable update)")]
        public string AssemblyVersion { get; set; }

        /// <summary>
        ///     Sets the assembly file version.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(current)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(increment)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly file version. (null to disable update)")]
        public string AssemblyFileVersion { get; set; }

        /// <summary>
        ///     Sets the assembly informational version.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly informational version. (null to disable update)")]
        public string AssemblyInformationalVersion { get; set; }

        /// <summary>
        ///     Sets the company name.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the company name. (null to disable update)")]
        public string AssemblyCompany { get; set; }

        /// <summary>
        ///     Sets the assembly configuration.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly configuration. (null to disable update)")]
        public string AssemblyConfiguration { get; set; }

        /// <summary>
        ///     Sets the assembly copyright.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly copyright. (null to disable update)")]
        public string AssemblyCopyright { get; set; }

        /// <summary>
        ///     Sets the assembly culture.
        /// </summary>
        /// <remarks>
        ///     Setting the value to null will disable updating this attribute.
        /// </remarks>
        [Description("Specify the assembly culture. (null to disable update)")]
        public string AssemblyCulture { get; set; }

        /// <summary>
        ///     Set to <b>true</b> to mark the assembly for delay signing.
        /// </summary>
        /// <remarks>
        ///     Setting the value to null will disable updating this attribute.
        /// </remarks>
        [Description("Specify whether to delay sign the assembly. (null to disable update)")]
        public bool? AssemblyDelaySign { get; set; }

        /// <summary>
        ///     Sets the assembly description.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly description. (null to disable update)")]
        public string AssemblyDescription { get; set; }

        /// <summary>
        ///     Sets the assembly GUID.
        /// </summary>
        /// <remarks>
        ///     Setting the value to null will disable updating this attribute.
        /// </remarks>
        [Description("Specify the assembly GUID. (null to disable update)")]
        public Guid? Guid { get; set; }

        /// <summary>
        ///     Sets the key file to use to sign the assembly.
        /// </summary>
        /// <remarks>
        ///     Setting the value to null will disable updating this attribute.
        /// </remarks>
        [Description("Specify the key file to use to sign the assembly. (null to disable update)")]
        public string AssemblyKeyFile { get; set; }

        /// <summary>
        ///     Sets the name of a key container within the CSP containing the key pair used to generate a strong name.
        /// </summary>
        /// <remarks>
        ///     Setting the value to null will disable updating this attribute.
        /// </remarks>
        [Description(
            "Specify the name of the key conteiner to use to generate a strong name. (null to disable update)")]
        public string AssemblyKeyName { get; set; }

        /// <summary>
        ///     Sets the assembly product.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly product. (null to disable update)")]
        public string AssemblyProduct { get; set; }

        /// <summary>
        ///     Sets the assembly title.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly title. (null to disable update)")]
        public string AssemblyTitle { get; set; }

        /// <summary>
        ///     Sets the assembly trademark.
        /// </summary>
        /// <remarks>
        ///     <para>Setting the value to null will disable updating this attribute.</para>
        ///     <para>
        ///         The following tokens are supported (see <see cref="AssemblyInfoUpdater" /> remarks for a description of those tokens):
        ///         <list type="bullet">
        ///             <item>
        ///                 <description>$(version)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(fileversion)</description>
        ///             </item>
        ///             <item>
        ///                 <description>$(date:&lt;format&gt;)</description>
        ///             </item>
        ///         </list>
        ///     </para>
        /// </remarks>
        [Description("Specify the assembly trademark. (null to disable update)")]
        public string AssemblyTrademark { get; set; }

        /// <summary>
        ///     Set to <b>true</b> to mark the assembly CLS compliant.
        /// </summary>
        /// <remarks>
        ///     Setting the value to null will disable updating this attribute.
        /// </remarks>
        [Description("Specify whether the assembly is CLS compliant. (null to disable update)")]
        public bool? CLSCompliant { get; set; }

        /// <summary>
        ///     Set to <b>true</b> to make the assembly visible to COM.
        /// </summary>
        /// <remarks>
        ///     Setting the value to null will disable updating this attribute.
        /// </remarks>
        [Description("Specify whether the assembly is COM visible. (null to disable update)")]
        public bool? ComVisible { get; set; }

        [Description("Specifiy whether or not to add missing attribute.")]
        public bool? EnsureAttribute { get; set; }

        [Description("Gets the custom attributes.")]
        public Hashtable CustomAttributes { get; set; }

        public UpdateAssemblyInfo Cmdlet { get; set; }

        #endregion

        /// <summary>
        ///     Executes the logic for this workflow activity.
        /// </summary>
        public List<UpdateResult> InternalExecute()
        {
            this.Cmdlet.WriteDebug("InternalExecute");

            var assemblyVersion = string.Empty;
            var assemblyFileVersion = string.Empty;
            this.tokenEvaluators = new Dictionary<string, Func<string, string>>
            {
                {"current", p => "-1"},
                //{"increment", p => "-1"},
                {"version", p => assemblyVersion},
                {"fileversion", p => assemblyFileVersion}
            };

            var updateResults = new List<UpdateResult>();
            
            if (this.Files == null || !this.Files.Any())
            {
                this.Cmdlet.WriteDebug("no files");
                return updateResults;
            }

            foreach (var path in this.Files)
            {
                this.Cmdlet.WriteDebug("path: " + path);
                if (!File.Exists(path))
                {
                    throw new FileNotFoundException("AssemblyInfo file not found.", path);
                }

                this.file = new AssemblyInfoFile(this.Cmdlet, path, this.EnsureAttribute);

                assemblyVersion = this.UpdateVersion("AssemblyVersion", this.AssemblyVersion);
                this.Cmdlet.WriteDebug("assemblyVersion: " + assemblyVersion);
                assemblyFileVersion = this.UpdateVersion("AssemblyFileVersion", this.AssemblyFileVersion);
                this.Cmdlet.WriteDebug("assemblyFileVersion: " + assemblyFileVersion);

                var infoVersion = this.UpdateAttribute("AssemblyInformationalVersion", this.AssemblyInformationalVersion, true);
                this.Cmdlet.WriteDebug("infoVersion: " + infoVersion);

                // update other attributes
                this.UpdateAttribute("AssemblyCompany", this.AssemblyCompany, true);
                this.UpdateAttribute("AssemblyConfiguration", this.AssemblyConfiguration, true);
                this.UpdateAttribute("AssemblyCopyright", this.AssemblyCopyright, true);
                this.UpdateAttribute("AssemblyDescription", this.AssemblyDescription, true);
                this.UpdateAttribute("AssemblyProduct", this.AssemblyProduct, true);
                this.UpdateAttribute("AssemblyTitle", this.AssemblyTitle, true);
                this.UpdateAttribute("AssemblyTrademark", this.AssemblyTrademark, true);
                this.UpdateAttribute("AssemblyCulture", this.AssemblyCulture, false);
                this.UpdateAttribute("AssemblyDelaySign",
                    this.AssemblyDelaySign.HasValue ? (object) this.AssemblyDelaySign.Value : null, false);
                this.UpdateAttribute("Guid", this.Guid.HasValue ? this.Guid.Value.ToString() : null, false);
                this.UpdateAttribute("AssemblyKeyFile", this.AssemblyKeyFile, false);
                this.UpdateAttribute("AssemblyKeyName", this.AssemblyKeyName, false);
                this.UpdateAttribute("CLSCompliant",
                    this.CLSCompliant.HasValue ? (object) this.CLSCompliant.Value : null, false);
                this.UpdateAttribute("ComVisible", this.ComVisible.HasValue ? (object) this.ComVisible.Value : null,
                    false);

                if (this.CustomAttributes != null)
                {
                    foreach (DictionaryEntry entry in this.CustomAttributes)
                    {
                        this.UpdateAttribute(entry.Key.ToString(), entry.Value, false);
                    }
                }

                // write to file (unset and set back ReadOnly attribute if present).
                var fileAttributes = File.GetAttributes(path);
                var attributesChanged = false;

                if ((fileAttributes & FileAttributes.ReadOnly) == FileAttributes.ReadOnly)
                {
                    File.SetAttributes(path, fileAttributes ^ FileAttributes.ReadOnly);
                    attributesChanged = true;
                }

                using (var sw = new StreamWriter(path, false, Encoding.UTF8))
                {
                    this.file.Write(sw);
                }

                if (attributesChanged)
                {
                    File.SetAttributes(path, FileAttributes.ReadOnly);
                }

                var updateResult = new UpdateResult()
                {
                    File = path,
                    FileVersion = assemblyFileVersion,
                    AssemblyVersion = assemblyVersion
                };
                this.Cmdlet.WriteDebug("updateResult.File: " + updateResult.File);
                this.Cmdlet.WriteDebug("updateResult.FileVersion: " + updateResult.FileVersion);
                this.Cmdlet.WriteDebug("updateResult.AssemblyVersion: " + updateResult.AssemblyVersion);

                updateResults.Add(updateResult);
            }

            return updateResults;
        }


        // Updates and returns the version of the specified attribute.
        private string UpdateVersion(string attributeName, string format)
        {
            this.Cmdlet.WriteDebug("UpdateVersion");
            this.Cmdlet.WriteDebug("attributeName: " + attributeName);
            this.Cmdlet.WriteDebug("format: " + format);
            if (string.IsNullOrEmpty(format))
            {
                this.Cmdlet.WriteDebug("no format");
                return string.Empty;
            }

            var oldObject = this.file[attributeName];
            if (oldObject == null)
            {
                this.Cmdlet.WriteDebug("attributeLine not found");
                return string.Empty;
            }

            var oldValue = oldObject.ToString();
            this.Cmdlet.WriteDebug("oldValue: " + oldValue);

            // parse old version (handle * character)
            var containsWildcard = oldValue.Contains('*');
            var versionPattern = "{0}.{1}.{2}.{3}";

            if (containsWildcard)
            {
                if (oldValue.Split('.').Length == 3)
                {
                    oldValue = oldValue.Replace("*", "0.0");
                    versionPattern = "{0}.{1}.*";
                }
                else
                {
                    oldValue = oldValue.Replace("*", "0");
                    versionPattern = "{0}.{1}.{2}.*";
                }
            }

            if (!VersionParser.IsMatch(oldValue))
            {
                throw new FormatException("Current value for attribute '" + attributeName +
                                          "' is not in a correct version format.");
            }

            var version = new Version(oldValue);

            // update version
            var tokens = format.Split('.');
            if (tokens.Length != 4)
            {
                throw new FormatException("Specified value for attribute '" + attributeName +
                                          "'  is not a correct version format.");
            }

            version = new Version(Convert.ToInt32(this.ReplaceTokens(tokens[0], version.Major)),
                Convert.ToInt32(this.ReplaceTokens(tokens[1], version.Minor)),
                Convert.ToInt32(this.ReplaceTokens(tokens[2], version.Build)),
                Convert.ToInt32(this.ReplaceTokens(tokens[3], version.Revision)));
            this.Cmdlet.WriteDebug("version: " + version);


            this.file[attributeName] = string.Format(versionPattern, version.Major, version.Minor, version.Build,
                version.Revision);

            return version.ToString();
        }

        // Updates and returns the value of the specified attribute.
        private object UpdateAttribute(string attributeName, object attributeValue, bool replaceTokens)
        {
            this.Cmdlet.WriteDebug("UpdateAttribute");
            this.Cmdlet.WriteDebug("attributeName: " + attributeName);
            this.Cmdlet.WriteDebug("attributeValue: " + attributeValue);
            this.Cmdlet.WriteDebug("replaceTokens: " + replaceTokens);
            if (attributeValue == null)
            {
                this.Cmdlet.WriteDebug("no attribute value");
                return string.Empty;
            }

            this.file[attributeName] = replaceTokens
                ? this.ReplaceTokens(attributeValue.ToString(), default(int))
                : attributeValue;

            return this.file[attributeName];
        }

        // Expands the specified token.
        private string ReplaceTokens(string value, int current)
        {
            this.Cmdlet.WriteDebug("ReplaceTokens");
            this.Cmdlet.WriteDebug("value: " + value);
            this.Cmdlet.WriteDebug("current: " + current);
            // define replace functions
            this.tokenEvaluators["current"] = p => current.ToString();
            this.tokenEvaluators["increment"] = p => (current + 1).ToString();

            // replace tokens
            return TokenParser.Replace(
                value,
                m =>
                {
                    var evaluator = default(Func<string, string>);
                    if (!this.tokenEvaluators.TryGetValue(m.Groups["token"].Value, out evaluator))
                    {
                        throw new FormatException("Unknown token '" + m.Groups["token"].Value + "'.");
                    }

                    return evaluator(m.Groups["param"].Value);
                });
        }
    }
}