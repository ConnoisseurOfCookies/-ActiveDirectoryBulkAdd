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
<p>Follow the format set up in the CSV or Json files, it is quite self-explanatory. Be careful editing .csv files with Excel, it tends to screw up the formatting or try to save it in a different format. Personally I'd use VSCode, for the syntax highlighting, or just stick with the JSON.</p>
<ol>
    <li><p>Place the script and the csv/json file in the same folder</p></li>
    <li><p>Edit the relevant details. Note that OU follows the format "OU=*OU*, DC=*Domain Name pt1*, DC=*Domain Name pt2*"</p></li>
    <li><p>And for christ's sake, please change the details if you're using this for a school submission. You don't wanna get pinged for plagiarism</p></li>
    <li><p>Make sure you haven't changed the filenames</p></li>
    <li><p>Run the script from the folder with admin/escalated privileges (even if you're logged in as admin)</p></li>
</ol>

<h3>Just Reference the Script file in the command line</h3>

```PowerShell
    cd .\Your\Directory
    .\addAdUsersCSV.ps1 or .\addAdUsersJson.ps1  
```

<h2 id="issues">Issues<h2>

<ul>
    <li>No error handling code</li>
    <li>No checking for edge cases</li>
    <li>No handling of duplicate users</li>
</ul>

<h2 id="references">Reference</h2>
Implemented as per video from <a href="https://www.youtube.com/watch?v=9WAcQE-Q9xo">Server Academy Youtube Channel</a>
