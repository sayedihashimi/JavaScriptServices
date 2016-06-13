[cmdletbinding()]
param()

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'Angular2'
    Type = 'ProjectTemplate'
    # TODO: Customize
    DefaultProjectName = 'Angular2App'
    CreateNewFolder = $false
    AfterInstall = {
        Update-PWPackagesPathInProjectFiles -slnRoot ($SolutionRoot)
    }
}

$templateInfo | replace (
    # TODO: customize and add extra replacements as needed
    ('WebApplicationBasic', {"$ProjectName"}, {"$DefaultProjectName"}),
    ('Angular2Spa', {"$ProjectName"}, {"$DefaultProjectName"}),
    
    # TODO: Replace with project guids from your projects, try script below
    ('8f5cb8a9-3086-4b49-a1c2-32a9f89bca11', {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj"))
)

# when the template is run any filename with the given string will be updated
$templateInfo | update-filename (
    # TODO: customize based on your project names
    ,('Angular2Spa', {"$ProjectName"},$null,@('*.*proj'))
)
# excludes files from the template
$templateInfo | exclude-file 'pw-*.*','*.user','*.suo','*.userosscache','project.lock.json','*.vs*scc','*.sln','_project.vstemplate'
# excludes folders from the template
$templateInfo | exclude-folder '.vs','artifacts','packages','bin','obj' 

# This will register the template with pecan-waffle
Set-TemplateInfo -templateInfo $templateInfo

<#
To add to speed up restore experience
    AfterInstall = {
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
        $projdest = $properties['FinalDestPath']
        $filetoextract = (Join-Path $projdest 'n-modules.7z')

        try{
            Push-Location

            # see if the file has already been extracted
            $extractdest = ([System.IO.DirectoryInfo](Join-Path $env:LOCALAPPDATA 'pecan-waffle\aur2016\nmv1')).FullName

            if(-not (Test-Path $extractdest)){
                New-Item -Path $extractdest -ItemType Directory

                Set-Location $extractdest

                $7zippath = (Get-7zipExe)

                if( -not ([string]::IsNullOrWhiteSpace($filetoextract)) -and (Test-Path $filetoextract) ){
                    $cmdargs = @('-bd','x',$filetoextract,('-w{0}' -f $extractdest))

                    $cmdargsstr = "`r`n{0} {1}" -f $7zippath,($cmdargs -join ' ')

                    if(-not [string]::IsNullOrWhiteSpace($logfilepath)){
                        [System.IO.File]::AppendAllText($logfilepath, $cmdargsstr)
                    }

                    Invoke-CommandString -command $7zippath -commandArgs $cmdargs -ignoreErrors $true
                }
                else{
                    throw ('Did not find node modules zip at [{0}]' -f $filetoextract)
                }
            }

            if(-not ([string]::IsNullOrEmpty($projdest)) -and (test-path $projdest) ){
                if(-not (Test-Path $extractdest)){
                    throw ('node modules content folder not found at [{0}]' -f $extractdest)
                }

                $nmdest = ([System.IO.DirectoryInfo](Join-Path $projdest 'node_modules')).FullName
                Copy-ItemRobocopy -sourcePath "$extractdest\node_modules" -destPath $nmdest -recurse

            }
            else{
                'destPath is empty' | Write-Output

                if(-not [string]::IsNullOrWhiteSpace($logfilepath)){
                    [System.IO.File]::AppendAllText('c:\temp\pean-waffle\log.txt','destPath is empty')
                }
            }
        }
        finally{
            if(Test-Path $filetoextract){
                Remove-Item $filetoextract
            }
            Pop-Location
        }        
    }
#>



<#
Use this one-liner to figure out the include expression for the project name
>Get-ChildItem .\templates * -Recurse -File|select-string 'Contoso' -SimpleMatch|Select-Object -ExpandProperty path -Unique|% { Get-Item $_ | Select-Object -ExpandProperty extension}|Select-Object -Unique|%{ Write-Host "'$_';" -NoNewline }


'.sln';'.vstemplate';'.csproj';'.bak';'.cs';'.xml';'.plist';'.projitems';'.shproj';'.xaml';'.config';'.pubxml';'.appxmanifest'

Use this one-liner to figure out the guids in your template
> Get-ChildItem .\templates *.*proj -Recurse -File|Select-Object -ExpandProperty fullname -Unique|% { ([xml](Get-Content $_)).Project.PropertyGroup.ProjectGuid|Select-Object -Unique|%{ '({0}, {{"$ProjectId"}}, [System.Guid]::NewGuid(),@("*.*proj")),' -f $_ }}

({8EBB17C5-5B87-466B-99BE-709C04F71BC8}, {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),
({B095DC2E-19D7-4852-9450-6774808B626E}, {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),
(e651c0cb-f5fb-4257-9289-ef45f3c1a02c, {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),
(1dfffd59-6b32-4937-bfde-1e10c11d22c3, {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),
({4D2348EA-44AA-479F-80FB-EF67D64F4F3A}, {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),
({0A7800A3-784F-4822-8956-7BAC2C4D194E}, {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),
({6B0A711C-8401-4240-BA08-A8198EFC271E}, {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),


use this one-liner to figure out the include statement for update-filename
Get-ChildItem C:\temp\pean-waffle\dest\new3 *Contoso* -Recurse -File|Select-Object -ExpandProperty extension -Unique|%{ write-host ( '''{0}'',' -f $_) -NoNewline }

'.csproj','.bak','.projitems','.shproj','.cs'
#>