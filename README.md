<h1>AD Bulk User Adder</h1>

<h2>Index</h2>
<ul>
    <li><a href="#purpose">Purpose</a></li>
    <li><a href="#instructions">Instructions</a></li>
    <li><a href="#issues">Issues</a></li>
    <li><a href="#references">Reference</a></li>
</ul>

<h2 id="purpose">Purpose</h2>
<p>The purpose of this script is to add bulk users to Windows Active Directory by using either a CSV or a JSON file</p>

<h2 id="instructions">Instructions</h2>
<p>Follow the format as presented in the JSON sample file, it is quite self-explanatory. You will be prompted whether or not you want to create a default password for all users or whether you want to type them in individually. I have removed the option to read unique passwords from plaintext in a file since it is awful OPSEC. If you want to do that, for lab-purposes as an example, then you can look up versions of the script older than 11/1/2023.</p>
<p><b><s>Make sure that the organization structure, OU's and groups, have been defined and created prior to running the script</s></b> The script now scrapes the file for OU's and Groups and checks them against groups that already exist. If the user is a part of a group that doesn't exist the script prompts whether or not to create a new OU.</p>
<ol>
    <li><p>Modify the addAdUsers.json folder</p></li>
    <li><p>Edit the relevant details. Note the formatting for the "OU=ouUnit" and "DC=Domain,DC=DomainSuffix"</p></li>
    <li><p>And for christ's sake, please change the details if you're using this for a school submission. You don't wanna get pinged for plagiarism</p></li>
    <li><p>Make sure you haven't changed the filenames</p></li>
    <li><p>Run the script from the folder with admin/escalated privileges (even if you're logged in as admin)</p></li>
</ol>

<h3>Just Reference the Script file in the command line</h3>

```PowerShell
    cd .\Your\Directory
    .\addAdUsers.ps1  
```

<h2 id="issues">Issues</h2>
<ul>
    <li>Need to create a basic modification to handle different input formats (csv, xml, sql, mongoDB etc.)</li>
    <li><s>Drop the .CSV format, it is an objectively horrible formatting standard</s></li>
    <li><s>No</s> Basic error handling code</li>
    <li><s>No</s> Some checking for edge cases</li>
    <li><s>No handling of duplicate users</s></li>
    <li><s>OU's and Groups need to be created prior to running the script</s></li>
</ul>

<h2>Todo</h2>
    <ul>
        <li><s>Provide handling mechanisms for when OU's don't exist</s>Done!</li>
        <li><s>Prompt the user on whethere or not they would like for new OU's to be created</s></li>
        <li>Improve prompts. Could do with some more work</li>
        <li>Create utility for Home and Group folder creation with prerequisite permissions</li>
        <li>Create script that serialises, pulls and backs up AD details and configurations, so it can be rebuilt from scratch</li>
        <li>Break script into smaller modules, separated by folders and files</li>
        <li><s>Push JSON file down into a 'samples' directory</s></li>
        <li><s>Configure a "Configure Password prompt" at the start, prompt for either "Generic for All" password or "On individual basis"</s></li>
    </ul>


<h2 id="references">Reference</h2>
Initial implementation as per video from <a href="https://www.youtube.com/watch?v=9WAcQE-Q9xo">Server Academy Youtube Channel</a>
