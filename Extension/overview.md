# Update Assembly Info
Update assembly info of one or multiple projects during build.

## Usage
Add a new **Update Assembly Info** task from the **Utility** category...

![Task](images/task.png)

...and configure it as needed.

![Parameters](images/screenshot.png)
Parameters include:
* **Assembly Info**: Relative path from repo root of the assembly info file(s). Variables can be used, eg. `$(Build.SourcesDirectory)`. You can also use wildcards, eg. `**\AssemblyInfo.*` for all AssemblyInfo.* files in all sub folders.
* **Description**: Left blank, the value is not updated. Variables can be used including these task-specific variables:
    * `$(Assembly.Company)`: The value provided for Company.
    * `$(Assembly.Product)`: The value provided for Product.
    * `$(Assembly.Year)`: Provides the current year.
    Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **Configuration**: Left blank, the value is not updated. Variables can be used, eg. `$(BuildConfiguration)`. Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **Company**: Left blank, the value is not updated. Variables can be used. Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **Product**: Left blank, the value is not updated. Variables can be used. Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **Copyright**: Left blank, the value is not updated. Variables can be used, including these task-specific variables:
    * `$(Assembly.Company)`: The value provided for Company.
    * `$(Assembly.Product)`: The value provided for Product.
    * `$(Assembly.Year)`: Provides the current year.
    Used togeather this could produce "Copyright © YourCompanyName 2017".

    Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **Trademark**: Left blank, the value is not updated. Variables can be used, including these task-specific variables:
    * `$(Assembly.Company)`: The value provided for Company.
    * `$(Assembly.Product)`: The value provided for Product.
    Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **Informational Version**: Left blank, the value is not updated. Variables can be used, inlcuding these task-specific variables:
    * `$(Assembly.FileVersion)`: The assembly file version value.
    * `$(Assembly.FileVersionMajor)`: The assembly file version major value. Requires Major to be specified.
    * `$(Assembly.FileVersionMinor)`: The assembly file version minor value. Requires Minor to be specified.
    * `$(Assembly.FileVersionBuild)`: The assembly file version build value. Requires Build to be specified.
    * `$(Assembly.FileVersionRevision)`: The assembly file version revision value. Requires Revision to be specified.
    Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **File Version - Major**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **File Version - Minor**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **File Version - Build**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.
* **File Version - Revision**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Use `$(Invalid)` to throw error and force the user to change the value to something useful. This can be useful when used in task groups or creating templates.

## Having Problems?
Please [create an issue on our Github](https://github.com/BoolBySigma/UpdateAssemblyInfo/issues) and we will try to help you.

Icons made by [Freepik](http://www.freepik.com) from [Flaticon](http://www.flaticon.com) is licensed by [CC 3.0 BY](http://creativecommons.org/licenses/by/3.0/)