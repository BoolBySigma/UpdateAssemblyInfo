namespace Bool.PowerShell.UpdateAssemblyInfo
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.ComponentModel;
    using System.Globalization;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Text.RegularExpressions;

    public class AssemblyInfoUpdater
    {
        #region Methods

        /// <summary>
        ///     Executes the logic for this workflow activity.
        /// </summary>
        public List<UpdateResult> InternalExecute()
        {
            // initialize values
            var now = DateTime.Now;
            var version = string.Empty;
            var fileVersion = string.Empty;
            var versions = new List<Version>();
            var fileVersions = new List<Version>();
            var infoVersions = new List<string>();
            this.tokenEvaluators = new Dictionary<string, Func<string, string>> { { "current", p => "-1" }, { "increment", p => "-1" }, { "date", p => now.ToString(p, CultureInfo.InvariantCulture) }, { "version", p => version }, { "fileversion", p => fileVersion } };

            this.MaxAssemblyVersion = new Version(0, 0, 0, 0);
            this.MaxAssemblyFileVersion = new Version(0, 0, 0, 0);
            this.MaxAssemblyInformationalVersion = string.Empty;
            this.AssemblyVersions = new List<Version>();
            this.AssemblyFileVersions = new List<Version>();
            this.AssemblyInformationalVersions = new List<string>();

            var result = new List<UpdateResult>();

            // update all files
            var files = this.Files;
            if (files != null && files.Any())
            {
                foreach (var path in files)
                {
                    // load file
                    if (!File.Exists(path))
                    {
                        throw new FileNotFoundException("AssemblyInfo file not found.", path);
                    }

                    this.file = new AssemblyInfoFile(path, this.EnsureAttribute);

                    // update version attributes
                    version = this.UpdateVersion("AssemblyVersion", this.AssemblyVersion, this.MaxAssemblyVersion);

                    var parsedVersion = default(Version);
                    if (Version.TryParse(version, out parsedVersion))
                    {
                        versions.Add(parsedVersion);
                    }

                    fileVersion = this.UpdateVersion("AssemblyFileVersion", this.AssemblyFileVersion, this.MaxAssemblyFileVersion);

                    if (Version.TryParse(fileVersion, out parsedVersion))
                    {
                        fileVersions.Add(parsedVersion);
                    }

                    var infoVersion = this.UpdateAttribute("AssemblyInformationalVersion", this.AssemblyInformationalVersion, true);
                    if (string.Compare(infoVersion, this.MaxAssemblyInformationalVersion, StringComparison.Ordinal) > 0)
                    {
                        this.MaxAssemblyInformationalVersion = infoVersion;
                    }

                    infoVersions.Add(infoVersion);

                    // update other attributes
                    this.UpdateAttribute("AssemblyCompany", this.AssemblyCompany, true);
                    this.UpdateAttribute("AssemblyConfiguration", this.AssemblyConfiguration, true);
                    this.UpdateAttribute("AssemblyCopyright", this.AssemblyCopyright, true);
                    this.UpdateAttribute("AssemblyDescription", this.AssemblyDescription, true);
                    this.UpdateAttribute("AssemblyProduct", this.AssemblyProduct, true);
                    this.UpdateAttribute("AssemblyTitle", this.AssemblyTitle, true);
                    this.UpdateAttribute("AssemblyTrademark", this.AssemblyTrademark, true);
                    this.UpdateAttribute("AssemblyCulture", this.AssemblyCulture, false);
                    this.UpdateAttribute("AssemblyDelaySign", this.AssemblyDelaySign.HasValue ? this.file.BooleanToString(this.AssemblyDelaySign.Value) : null, false);
                    this.UpdateAttribute("Guid", this.Guid.HasValue ? this.Guid.Value.ToString() : null, false);
                    this.UpdateAttribute("AssemblyKeyFile", this.AssemblyKeyFile, false);
                    this.UpdateAttribute("AssemblyKeyName", this.AssemblyKeyName, false);
                    this.UpdateAttribute("CLSCompliant", this.CLSCompliant.HasValue ? this.file.BooleanToString(this.CLSCompliant.Value) : null, false);
                    this.UpdateAttribute("ComVisible", this.ComVisible.HasValue ? this.file.BooleanToString(this.ComVisible.Value) : null, false);

                    foreach (DictionaryEntry entry in this.CustomAttributes) {
                        this.UpdateAttribute(entry.Key.ToString(), entry.Value.ToString(), false);
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

                    result.Add(new UpdateResult()
                    {
                        File = path,
                        FileVersion = fileVersion,
                        AssemblyVersion = version
                    });
                }

                this.AssemblyVersions = versions;
                this.AssemblyFileVersions = fileVersions;
                this.AssemblyInformationalVersions = infoVersions;
            }

            return result;
        }

        #endregion

        #region Fields

        // token parser.
        private static readonly Regex TokenParser = new Regex(@"\$\((?<token>[^:\)]*)(:(?<param>[^\)]+))?\)", RegexOptions.Compiled | RegexOptions.IgnoreCase);

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
        [Description("Specify the name of the key conteiner to use to generate a strong name. (null to disable update)")]
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

        /// <summary>
        ///     Gets the max updated assembly version.
        /// </summary>
        [Description("Gets the max computed assembly version.")]
        public Version MaxAssemblyVersion { get; set; }

        /// <summary>
        ///     Gets the max updated assembly file version.
        /// </summary>
        [Description("Gets the max computed assembly file version.")]
        public Version MaxAssemblyFileVersion { get; set; }

        /// <summary>
        ///     Gets the max updated assembly informational version.
        /// </summary>
        [Description("Gets the max computed assembly informational version.")]
        public string MaxAssemblyInformationalVersion { get; set; }

        /// <summary>
        ///     Gets the updated assembly versions.
        /// </summary>
        [Description("Gets the updated assembly versions.")]
        public IEnumerable<Version> AssemblyVersions { get; set; }

        /// <summary>
        ///     Gets the max updated assembly file versions.
        /// </summary>
        [Description("Gets the updated assembly file versions.")]
        public IEnumerable<Version> AssemblyFileVersions { get; set; }

        /// <summary>
        ///     Gets the updated assembly informational versions.
        /// </summary>
        [Description("Gets the updated assembly informational versions.")]
        public IEnumerable<string> AssemblyInformationalVersions { get; set; }

        [Description("Specifiy whether or not to add missing attribute.")]
        public bool? EnsureAttribute { get; set; }

        [Description("Gets the custom attributes.")]
        public Hashtable CustomAttributes { get; set; }

        #endregion

        #region Private Helpers

        // Updates and returns the version of the specified attribute.
        private string UpdateVersion(string attributeName, string format, Version maxVersion)
        {
            /*if (string.IsNullOrWhiteSpace(format)) {
                return string.Empty;
            }*/
            
            if (string.IsNullOrEmpty(format) || (this.EnsureAttribute.HasValue && !this.EnsureAttribute.Value))
            {
                return string.Empty;
            }

            var oldValue = this.file[attributeName];
            if (oldValue == null)
            {
                return string.Empty;
            }

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
                throw new FormatException("Current value for attribute '" + attributeName + "' is not in a correct version format.");
            }

            var version = new Version(oldValue);

            // update version
            var tokens = format.Split('.');
            if (tokens.Length != 4)
            {
                throw new FormatException("Specified value for attribute '" + attributeName + "'  is not a correct version format.");
            }

            version = new Version(Convert.ToInt32(this.ReplaceTokens(tokens[0], version.Major)), Convert.ToInt32(this.ReplaceTokens(tokens[1], version.Minor)), Convert.ToInt32(this.ReplaceTokens(tokens[2], version.Build)), Convert.ToInt32(this.ReplaceTokens(tokens[3], version.Revision)));

            this.file[attributeName] = string.Format(versionPattern, version.Major, version.Minor, version.Build, version.Revision);

            if (version > maxVersion)
            {
                maxVersion = version;
            }

            return version.ToString();
        }

        // Updates and returns the value of the specified attribute.
        private string UpdateAttribute(string attributeName, string attributeValue, bool replaceTokens)
        {
            /*if (attributeValue == null || this.file[attributeName] == null)
            {
                // do nothing
                return string.Empty;
            }*/

            if (attributeValue == null || (this.EnsureAttribute.HasValue && !this.EnsureAttribute.Value))
            {
                return string.Empty;
            }

            this.file[attributeName] = replaceTokens ? this.ReplaceTokens(attributeValue, default(int)) : attributeValue;

            return this.file[attributeName];
        }

        // Expands the specified token.
        private string ReplaceTokens(string value, int current)
        {
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

        #endregion
    }
}