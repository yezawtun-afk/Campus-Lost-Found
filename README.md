# Campus Lost & Found Portal

A lost-and-found register for a university campus. Students and staff report what they
lost, hand in what they found, and search a single register of everything waiting at the
Security Office. Built with ASP.NET Web Forms and SQL Server LocalDB for a group project.

![The home page: the tagline sits across a coral and navy seam](docs/home.jpg)

## What it does

- **Report** a lost or found item, with an optional photo, in one form
- **Browse** every item in a card grid, filtered by category, sorted, and paged 9 at a time
- **Search** by keyword, category, location and status, in any combination
- **Manage** the register on an admin page: add, edit, delete, and change a status in one click
- **See** the four newest items on the home page, switchable between Lost, Found and Claimed

## Pages

| Page | Purpose |
| --- | --- |
| `Default.aspx` | Home: tagline, three calls to action, four recently reported items |
| `About.aspx` | Why the portal exists, how reporting works, and how to claim an item |
| `Items.aspx` | All items as cards, with category filter, sorting and pagination |
| `Search.aspx` | Keyword, category, location and status filters with a result count |
| `Report.aspx` | The report form, 10 fields, validation, photo upload |
| `Admin.aspx` | The register as an editable table, plus an add-item form |
| `Error.aspx` | Friendly error page, served by `<customErrors>` |

The Admin page is linked from the footer, not the main menu. There is no login, by design.

## Screens

| Items | Report |
| --- | --- |
| ![Item cards with Lost, Found and Claimed badges](docs/items.jpg) | ![The report form](docs/report.jpg) |

| Admin |
| --- |
| ![The editable admin table](docs/admin.jpg) |

## Tech stack

| Layer | Choice |
| --- | --- |
| Framework | ASP.NET Web Forms, .NET Framework 4.8 |
| Language | C# |
| Database | SQL Server Express LocalDB |
| Data access | ADO.NET (`SqlCommand` with parameters, `SqlDataAdapter`) |
| Front end | One master page, one stylesheet, plain HTML/CSS and a small JS file |
| Tooling | Visual Studio 2022 or newer, IIS Express |

## Getting started

### 1. What you need

- Visual Studio 2022 (or newer) with the **ASP.NET and web development** workload
- SQL Server Express LocalDB, which Visual Studio installs with that workload

### 2. Create the database (once)

Clone the repository, then run the script from the folder that contains it:

```powershell
git clone https://github.com/yezawtun-afk/Campus-Lost-Found.git
cd "Campus-Lost-Found"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i "CampusLostFound\Database\LostFoundDB.sql"
```

You should see:

```
TotalItems  TotalReports
----------  ------------
        12            12
```

The script drops and recreates `LostFoundDB`, so running it again resets the sample data.

If you prefer SQL Server Management Studio: connect to `(localdb)\MSSQLLocalDB`, open
`CampusLostFound\Database\LostFoundDB.sql`, and press Execute.

### 3. Open and run

1. Double-click `CampusLostFound.sln`.
2. Press **F5**. The site opens at `http://localhost:44300/`.

The connection string in `Web.config` already points at LocalDB:

```xml
<add name="LostFoundDB"
     connectionString="Data Source=(LocalDB)\MSSQLLocalDB;Initial Catalog=LostFoundDB;Integrated Security=True;MultipleActiveResultSets=True"
     providerName="System.Data.SqlClient" />
```

If your database lives elsewhere, change only `Data Source=` and `Initial Catalog=`.

### 4. Try it

- Search for **Wallet**: both wallets come back.
- Enter a search and press **Enter** instead of clicking Search.
- Open `Admin.aspx` from the footer and change a status, then delete a row (it asks first).

## Database

Two tables, one relationship.

| Table | Columns |
| --- | --- |
| `Items` | `ItemID` identity key, `ItemName`, `Description`, `Category`, `Location`, `DateReported`, `Status` (Lost / Found / Claimed, with a CHECK constraint), `ImagePath`, `ContactInfo` |
| `Reports` | `ReportID` identity key, `ItemID` foreign key to `Items` with `ON DELETE CASCADE`, `ReporterName`, `StudentStaffID`, `ReportType` (Lost / Found), `ReportDate` |

`Report.aspx` writes both rows inside one `SqlTransaction`, so an item is never saved
without its report. Deleting an item on the admin page removes its report rows too.

## Project structure

```
Campus Lost & Found/
  CampusLostFound.sln          Visual Studio solution
  docs/                        screenshots used by this README
  CampusLostFound/
    Site.master                shared header, navigation and footer
    Content/Site.css           the whole design system
    Content/site.js            page fades and the home status switch
    Default.aspx               home
    About.aspx                 about and how it works
    Items.aspx                 browse, filter, sort, page
    Search.aspx                search
    Report.aspx                report form
    Admin.aspx                 admin table and add form
    Error.aspx                 custom error page
    DbHelper.cs                connection + query helpers
    Database/LostFoundDB.sql   schema and 12 sample items
    Images/                    hero, about, placeholder and item photos
    Web.config                 connection string and customErrors
    README.txt                 the same instructions as plain text
```

All database access goes through `DbHelper.cs` and uses parameterised queries, so the
pages are safe from SQL injection.

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| "We could not connect to the database" | The database does not exist yet. Repeat step 2. |
| "Cannot open database LostFoundDB requested by the login" | Run the SQL script again while connected to `(localdb)\MSSQLLocalDB`. |
| An item shows a grey placeholder photo | Its image file is missing from `Images/items/`. The placeholder is expected. |
| A photo upload is rejected | Only JPG and PNG up to 4 MB are accepted. |

---

Built as a group project. No login or authentication is used.
