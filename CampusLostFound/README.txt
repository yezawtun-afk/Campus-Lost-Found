CAMPUS LOST & FOUND PORTAL
==========================
ASP.NET Web Forms (.NET Framework 4.8) + SQL Server LocalDB

A campus register for reporting lost items, handing in found items and
searching everything waiting at the Security Office. No login is used.

The long version of these instructions, with screenshots, is in README.md
at the top of the solution folder.


WHAT YOU NEED
-------------
1. Visual Studio 2022 or newer, with the "ASP.NET and web development" workload.
   To check: open the Visual Studio Installer, click Modify on your install,
   and look for that workload ticked.
2. SQL Server Express LocalDB (installed with that workload).
   To check, open PowerShell and run:   sqllocaldb info
   If it prints a name such as MSSQLLocalDB, you are ready.
3. This folder, copied anywhere on your computer.


STEP 1 - CREATE THE DATABASE (only once)
----------------------------------------
Option A - using SQL Server Management Studio (SSMS)
  1. Open SSMS and connect to:   (localdb)\MSSQLLocalDB
  2. File > Open > File...  and choose:  Database\LostFoundDB.sql
  3. Press Execute (F5). The script drops and recreates LostFoundDB,
     creates the Items and Reports tables, and inserts 12 sample items.

Option B - using PowerShell
  Open PowerShell in the folder that contains CampusLostFound.sln
  (the solution folder, one level above this window) and run:

  sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i "CampusLostFound\Database\LostFoundDB.sql"

  sqlcmd is the command line client for SQL Server. -S is the server,
  -E means "use my Windows account", -i is the file to run.

  You should see this at the end:

  TotalItems  TotalReports
  ----------- ------------
           12           12

  If you see 12 and 12, the database is ready.

  The script drops and recreates the database, so you can run it again
  at any time to reset the sample data.


STEP 2 - OPEN THE PROJECT
-------------------------
  Double-click:  CampusLostFound.sln
  (Visual Studio opens the whole solution and shows it in Solution Explorer.)


STEP 3 - CHECK THE CONNECTION STRING
------------------------------------
  Open Web.config and look at the <connectionStrings> section.
  It should read:

  <add name="LostFoundDB"
       connectionString="Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=LostFoundDB;Integrated Security=True;MultipleActiveResultSets=True"
       providerName="System.Data.SqlClient" />

  Data Source is the server, Initial Catalog is the database name.
  These match the script, so normally you do not change anything.
  If your database lives somewhere else, change only those two values.


STEP 4 - RUN IT
---------------
  Press F5 (or the green Start button).
  Visual Studio builds the project, starts IIS Express and opens the browser
  on http://localhost:44300/  (if a different port appears, use the address
  in the address bar).

  You should land on the home page: the tagline "Lost Something? Let Us
  Help You Find It." across a coral and navy seam, with three buttons.

  To stop the site, close the browser tab and press the red Stop button
  in Visual Studio (or press Shift+F5).


STEP 5 - CHECK IT WORKS
-----------------------
  - Home: "Recently reported" shows four cards with status badges.
  - Click Found in that section: only found items remain, the band changes.
  - Search: type Wallet and press Enter. "2 item(s) found", both wallets.
  - Lost & Found: click page 2. Items 10 to 12 of 12.
  - Admin (footer link): change a status, the badge updates immediately.
  - Admin: click Delete, a confirmation dialog appears first.


RUNNING IT AGAIN LATER
----------------------
  Open CampusLostFound.sln and press F5. The database stays on your machine
  between runs. Repeat Step 1 only to reset the sample data or if you moved
  the project to another computer.


PAGES
-----
  Default.aspx   Home: tagline, 3 buttons, recently reported items
  About.aspx     Purpose, how it works, reporting steps, claiming rules
  Items.aspx     All items, category filter, sorting, pagination
  Search.aspx    Search by keyword, category, location and status
  Report.aspx    Report a lost or found item (with optional photo)
  Admin.aspx     Add / edit / delete items, one-click status change
  Error.aspx     Friendly error page (used by <customErrors>)

  The Admin page is linked from the footer, not from the main menu.


HOW THE DATABASE IS USED
------------------------
  Items    - one row per reported item (name, description, category,
             location, date, status, image, contact).
  Reports  - one row per report (who reported it and how).
             Reports.ItemID is a foreign key with ON DELETE CASCADE,
             so deleting an item also deletes its report rows.

  All database access goes through DbHelper.cs and uses parameterised
  SqlCommand queries, so the app is safe from SQL injection.
  Report.aspx writes the Items and Reports rows inside one transaction.


TROUBLESHOOTING
---------------
  "We could not connect to the database..."
      -> The database does not exist yet. Repeat Step 1.
      -> Or the connection string in Web.config points to the wrong server.

  "Cannot open database LostFoundDB requested by the login"
      -> Run the SQL script again while connected to (localdb)\MSSQLLocalDB.

  sqlcmd is not recognised
      -> Open a new PowerShell window after installing Visual Studio, or run
         it from the SQL Server tools folder.

  The browser opens but the page is blank or shows an error
      -> Check that Step 1 printed 12 and 12, then reload.

  Photos do not appear
      -> Check that Images\items\*.jpg exist. Items with a missing file
         automatically show Images\placeholder.jpg.

  Upload fails
      -> Only JPG and PNG files up to 4 MB are accepted.


FOLDER MAP
----------
  Content\Site.css            one shared stylesheet (navy + coral theme)
  Site.master                 shared header, navigation and footer
  Database\LostFoundDB.sql    create tables + 12 sample items
  DbHelper.cs                 connection + query helpers
  Images\                     hero, about, placeholder and item photos
  Images\_source\             the SVG artwork the JPGs were made from

  The solution also has README.md at the top level, which is the version
  GitHub displays, plus docs\ with the screenshots it uses.


Built for a group project - no login or authentication is used.
