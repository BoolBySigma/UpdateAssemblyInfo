namespace Bool.PowerShell.UpdateAssemblyInfo
{
    internal class AttributeLine
    {
        // Gets or sets the string format to rewrite the attribute line with a new value.
        public string Format { get; set; }

        // Gets or sets the attribute value.
        public object Value { get; set; }

        // Gets or sets the attribute line number in the original file.
        public int LineNumber { get; set; }
    }
}