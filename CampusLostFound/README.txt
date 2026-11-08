CAMPUS LOST & FOUND PORTAL
==========================
ASP.NET Web Forms (.NET Framework 4.8) + SQL Server LocalDB

A campus register for reporting lost items, handing in found items and
searching everything waiting at the Security Office. No login is used.


WHAT YOU NEED
-------------
1. Visual Studio 2022 or newer, with the "ASP.NET and web development" workload.
2. SQL Server Express LocalDB (installed with Visual Studio).
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

  If you see TotalItems 12 and TotalReports 12, it worked.


STEP 2 - OPEN THE PROJECT
-------------------------
  Double-click:  CampusLostFound.sln
  (Visual Studio opens the whole solution.)


STEP 3 - CHECK THE CONNECTION STRING
------------------------------------
  Open Web.config and look at the <connectionStrings> section.
  It should read:

  <add name="LostFoundDB"
       connectionString="Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=LostFoundDB;Integrated Security=True;MultipleActiveResultSets=True"
       providerName="System.Data.SqlClient" />

  If your database lives somewhere else, change only the
  "Data Source=..." and "Initial Catalog=..." parts.


STEP 4 - RUN IT
---------------
  Press F5 (or the green Start button).
  Your browser opens on http://localhost:44300/


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


THINGS TO TRY
-------------
  - Search for "Wallet" - both wallets come back.
  - Type a keyword and press Enter instead of clicking Search.
  - Filter Items by category, then change the sort order.
  - On Admin, change a status in the dropdown (it saves immediately),
    then delete a row (it asks for confirmation first).


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
