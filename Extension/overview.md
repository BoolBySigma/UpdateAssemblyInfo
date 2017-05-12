# Update Assembly Info
Update assembly info of one or multiple files or projects during build. Supports a multitude of variables, formatting and detailed input options.

### Variables
The following variables can be used in all input fields
* **Build Variables**: all [Vsts Build Variables](https://www.visualstudio.com/en-us/docs/build/define/variables) can be used.

* **`$(Rev)`**: the build number revision. Requires **Allow Scripts to Access OAuth Token** to be **enabled** and the `$(Rev)` variable to be present in 'Build Number Format' (otherwise the information is not available on the build). Use `$(Rev:r)` for '1', `$(Rev:rr)` for '01', `$(Rev:rrr)` for '001' and so on.

* **`$(DayOfYear)`**: generates the numeric day of the year, eg. '116'.

* **`$(Date:{...})`**: generates date values in desired format.
    Examples:
    * `$(Date:yyyy)`: '2017' (Year in four digits)
    * `$(Date:MMMM)`: 'April'
    * `$(Date:MM)`  : '04' (Numeric month)
    * `$(Date:dddd)`: 'Sunday'
    * `$(Date:dd)`  : '23' (The day of the month)
    * `$(Date:HH)`  : '20' (The hour in24 hour format)
    * `$(Date:mm)`  : '22' (The minute)
    * `$(Date:ss)`  : '27' (The second)
    See [list of date formats](https://ss64.com/ps/syntax-dateformats.html) for more examples.

    Can be combined, with or without separators, to produce custom date formats.
    `$(Date:yyyy, MMMM, MM, dddd, dd, HH, mm, ss)` will generate eg. '2017, April, 04, Sunday, 23, 20, 22, 27'.

* **`$(Assembly.Company)`**: the value defined in the 'Company' input field.

* **`$(Assembly.Product)`**: the value defined in the 'Product' input field.

* **`$(Assembly.FileVersion)`**: The assembly file version value.

* **`$(Assembly.FileVersionMajor)`**: The assembly file version major value. Requires File Version Major to be specified.

* **`$(Assembly.FileVersionMinor)`**: The assembly file version minor value. Requires File Version Minor to be specified.

* **`$(Assembly.FileVersionBuild)`**: The assembly file version build value. Requires File Version Build to be specified.

* **`$(Assembly.FileVersionRevision)`**: The assembly file version revision value. Requires File Version Revision to be specified.

* **`$(Assembly.AssemblyVersion)`**: The assembly version value.

* **`$(Assembly.AssemblyVersionMajor)`**: The assembly version major value. Requires Assembly Version Major to be specified.

* **`$(Assembly.AssemblyVersionMinor)`**: The assembly version minor value. Requires Assembly Version Minor to be specified.

* **`$(Assembly.AssemblyVersionBuild)`**: The assembly version build value. Requires Assembly Version Build to be specified.

* **`$(Assembly.AssemblyVersionRevision)`**: The assembly version revision value. Requires Assembly Version Revision to be specified.

* **`$(Invalid)`**: throws an error and force the user to change the value to something useful. This can be useful when working with task groups or creating a template.
Defining eg. 'Description' as 'This description is $(Invalid)' or simply '$(Invalid)' will throw an error and force the user to specify a meningful description.

### Output Variables
Variables that can be used by subsequent tasks.
Values from the first assembly info file will be passed to variables if multiple files are updated.
* `$(Assembly.FileVersion)`: The assembly file version value.
* `$(Assembly.AssemblyVersion)`: The assembly version value.
* `$(Build.BuildNumberRevision)`: The build number revision as an integer. If you are using `$(Rev:rrr)` to generate eg. '004', `$(Build.BuildNumberRevision)` will output '4'.

## Usage
Add a new **Update Assembly Info** task from the **Utility** category...

![Task](images/task.png)

...and configure it as needed.

![Parameters](images/screenshot.png)
Parameters include:
* **Assembly Info**: Relative path from repo root of the assembly info file(s). Variables can be used, eg. `$(Build.SourcesDirectory)`. You can also use wildcards, eg. `**\AssemblyInfo.*` for all AssemblyInfo.* files in all sub folders.
* **Add Missing Attributes**: Adds attribute to assembly info file if it is missing. If the attribute is not specified in this task it will not be added.
* **Description**: Left blank, the value is not updated. Variables can be used including.
* **Configuration**: Left blank, the value is not updated. Variables can be used, eg. `$(BuildConfiguration)`.
* **Company**: Left blank, the value is not updated. Variables can be used.
* **Product**: Left blank, the value is not updated. Variables can be used.
* **Copyright**: Left blank, the value is not updated. Variables can be used.
* **Trademark**: Left blank, the value is not updated. Variables can be used.
* **Informational Version**: Left blank, the value is not updated. Variables can be used.
* **Com Visible**: Select value for Com Visible. If 'Do Not Update', the value is not updated.
* **CLS Compliant**: Select value for CLS Compliant. If 'Do Not Update', the value is not updated.
* **File Version - Major**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **File Version - Minor**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **File Version - Build**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **File Version - Revision**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **Assembly Version - Major**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **Assembly Version - Minor**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **Assembly Version - Build**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **Assembly Version - Revision**: Left blank, the value is not updated. Variables can be used, eg. `$(Build.BuildId)`. Must be a numeric value.
* **Custom Attributes**: Input custom attribute and value in format `AttributeName=AttributeValue`. Use a new line for each new custom attribute.
Example:
`AttributeName1=AttributeValue1`
`AttributeName2=AttributeValue2`
`AttributeName3=AttributeValue3`
If using attribute values 'True', 'true', 'False' or 'false' the custom attribute will be treated as a boolean attribute.
Left blank, no custom attributes are added. Variables can be used.

## Changelog
* **2.0.31**: Added 'CLS Compliant' attribute.
* **2.0.27**: Added 'Do Not Update' option for Com Visible attribute.
* **2.0.25**: Added support for custom attributes.
* **2.0.23**: Added $(Rev) variable.
* **2.0.20**: Added $(DayOfYear) variable.
* **2.0.18**: Added $(Date:{...}) variable. Enables adding missing attributes.
* **2.0.13**: Added support for alternate file names and output parameters.
* **2.0.11**: Added 'Com Visible' attribute.
* **2.0.0**: Added 'Assembly Version' attributes.

## Having Problems?
Please [create an issue on our Github](https://github.com/BoolBySigma/UpdateAssemblyInfo/issues) and we will try to help you.

Icons made by [Freepik](http://www.freepik.com) from [Flaticon](http://www.flaticon.com) is licensed by [CC 3.0 BY](http://creativecommons.org/licenses/by/3.0/)