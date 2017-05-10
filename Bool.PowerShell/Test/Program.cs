using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Bool.PowerShell.UpdateAssemblyInfo;

namespace Test
{
    class Program
    {
        static void Main(string[] args)
        {
            var updater = new AssemblyInfoUpdater();
            updater.Files = new List<string>(){"AssemblyInfo.cs", "AssemblyInfo.vb"};
            updater.AssemblyFileVersion = "$(current).$(current).$(current).12";
            updater.AssemblyDescription = "New Description";
            updater.EnsureAttribute = true;
            updater.ComVisible = true;
            updater.CLSCompliant = false;
            updater.CustomAttributes = new Hashtable {{"CustomBoolean", false}, {"CustomString", "Martin"}};

            updater.InternalExecute();
        }
    }
}
