using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace CampusLostFound
{
    /// <summary>
    /// Search page: keyword plus category, location and status filters over the Items table.
    /// </summary>
    public partial class Search : System.Web.UI.Page
    {
        /// <summary>
        /// Fills the filter dropdowns, wires the Enter key to the Search button and shows the first result set.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // Pressing Enter inside the form now triggers the Search button.
            if (Page.Form != null)
            {
                Page.Form.DefaultButton = btnSearch.UniqueID;
            }

            if (!IsPostBack)
            {
                LoadFilters();
                ApplyStatusFromQuery();
                RunSearch();
            }
        }

        /// <summary>
        /// Pre-selects the status filter when the page is opened from the home page
        /// status switch (Search.aspx?status=Lost), so the switch works without JavaScript.
        /// </summary>
        private void ApplyStatusFromQuery()
        {
            string status = Request.QueryString["status"];

            if (string.IsNullOrEmpty(status))
            {
                return;
            }

            ListItem match = ddlStatus.Items.FindByValue(status);
            if (match != null)
            {
                ddlStatus.ClearSelection();
                match.Selected = true;
            }
        }

        /// <summary>
        /// Loads the DISTINCT category and location lists from the database.
        /// </summary>
        private void LoadFilters()
        {
            try
            {
                ddlCategory.Items.Add(new ListItem("All categories", "All"));
                ddlLocation.Items.Add(new ListItem("All locations", "All"));

                DataTable categories = DbHelper.ExecuteQuery(
                    "SELECT DISTINCT Category FROM dbo.Items ORDER BY Category");
                foreach (DataRow row in categories.Rows)
                {
                    string value = Convert.ToString(row["Category"]);
                    ddlCategory.Items.Add(new ListItem(value, value));
                }

                DataTable locations = DbHelper.ExecuteQuery(
                    "SELECT DISTINCT Location FROM dbo.Items ORDER BY Location");
                foreach (DataRow row in locations.Rows)
                {
                    string value = Convert.ToString(row["Location"]);
                    ddlLocation.Items.Add(new ListItem(value, value));
                }
            }
            catch (Exception ex)
            {
                ShowError(DbHelper.FriendlyError(ex));
            }
        }

        /// <summary>
        /// Runs a parameterised search using every filter the user filled in.
        /// </summary>
        private void RunSearch()
        {
            try
            {
                string keyword = txtKeyword.Text.Trim();
                string category = ddlCategory.SelectedValue;
                string location = ddlLocation.SelectedValue;
                string status = ddlStatus.SelectedValue;

                string sql = @"SELECT ItemID, ItemName, Description, Category, Location, DateReported, Status, ImagePath
                               FROM dbo.Items
                               WHERE 1 = 1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(keyword))
                {
                    sql += " AND ItemName LIKE @Keyword";
                    // Wildcards are added to the value, never to the SQL text itself.
                    parameters.Add(new SqlParameter("@Keyword", SqlDbType.NVarChar, 110) { Value = "%" + keyword + "%" });
                }

                if (!string.IsNullOrEmpty(category) && !string.Equals(category, "All", StringComparison.OrdinalIgnoreCase))
                {
                    sql += " AND Category = @Category";
                    parameters.Add(new SqlParameter("@Category", SqlDbType.NVarChar, 50) { Value = category });
                }

                if (!string.IsNullOrEmpty(location) && !string.Equals(location, "All", StringComparison.OrdinalIgnoreCase))
                {
                    sql += " AND Location = @Location";
                    parameters.Add(new SqlParameter("@Location", SqlDbType.NVarChar, 100) { Value = location });
                }

                if (!string.IsNullOrEmpty(status) && !string.Equals(status, "All", StringComparison.OrdinalIgnoreCase))
                {
                    sql += " AND Status = @Status";
                    parameters.Add(new SqlParameter("@Status", SqlDbType.NVarChar, 20) { Value = status });
                }

                sql += " ORDER BY DateReported DESC, ItemID DESC";

                DataTable results = DbHelper.ExecuteQuery(sql, parameters.ToArray());

                rptResults.DataSource = results;
                rptResults.DataBind();

                pnlEmpty.Visible = results.Rows.Count == 0;
                litCount.Text = string.Format("{0} item(s) found", results.Rows.Count);
            }
            catch (Exception ex)
            {
                ShowError(DbHelper.FriendlyError(ex));
                pnlEmpty.Visible = false;
                litCount.Text = "Search failed";
            }
        }

        /// <summary>
        /// Search button click: re-runs the query with the current filters.
        /// </summary>
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            RunSearch();
        }

        /// <summary>
        /// Reset button click: clears every filter and shows the full list again.
        /// </summary>
        protected void btnReset_Click(object sender, EventArgs e)
        {
            txtKeyword.Text = string.Empty;
            ddlCategory.SelectedIndex = 0;
            ddlLocation.SelectedIndex = 0;
            ddlStatus.SelectedIndex = 0;
            pnlError.Visible = false;
            RunSearch();
        }

        /// <summary>
        /// Shows a friendly error strip above the results.
        /// </summary>
        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = Server.HtmlEncode(message);
        }

        /// <summary>
        /// Returns a usable image URL, falling back to the placeholder when the file is missing.
        /// </summary>
        public string ImageUrl(object imagePath)
        {
            string path = Convert.ToString(imagePath);

            if (!string.IsNullOrWhiteSpace(path))
            {
                string physicalPath = Server.MapPath(path);
                if (File.Exists(physicalPath))
                {
                    return ResolveUrl(path);
                }
            }

            return ResolveUrl("~/Images/placeholder.jpg");
        }

        /// <summary>
        /// Returns the colour-coded badge class for an item status.
        /// </summary>
        public string StatusCss(object status)
        {
            string value = Convert.ToString(status).ToLowerInvariant();
            if (value != "lost" && value != "found")
            {
                value = "claimed";
            }
            return "badge badge-" + value;
        }
    }
}
