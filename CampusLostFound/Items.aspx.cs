using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

namespace CampusLostFound
{
    /// <summary>
    /// Full list of items with a category filter, sorting and pagination (9 cards per page).
    /// </summary>
    public partial class Items : System.Web.UI.Page
    {
        private const int PageSize = 9;

        /// <summary>
        /// Builds the filter dropdowns once, then loads the item page requested in the URL.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategoryFilter();
            }

            LoadItems();
        }

        /// <summary>
        /// Fills the category dropdown with DISTINCT categories from the database.
        /// </summary>
        private void LoadCategoryFilter()
        {
            try
            {
                DataTable categories = DbHelper.ExecuteQuery(
                    "SELECT DISTINCT Category FROM dbo.Items ORDER BY Category");

                ddlCategory.Items.Clear();
                ddlCategory.Items.Add(new ListItem("All categories", "All"));

                foreach (DataRow row in categories.Rows)
                {
                    string category = Convert.ToString(row["Category"]);
                    ddlCategory.Items.Add(new ListItem(category, category));
                }

                string selected = Request.QueryString["category"];
                if (!string.IsNullOrEmpty(selected))
                {
                    ListItem match = ddlCategory.Items.FindByValue(selected);
                    if (match != null)
                    {
                        ddlCategory.ClearSelection();
                        match.Selected = true;
                    }
                }

                string sort = Request.QueryString["sort"];
                ListItem sortMatch = string.IsNullOrEmpty(sort) ? null : ddlSort.Items.FindByValue(sort);
                if (sortMatch != null)
                {
                    ddlSort.ClearSelection();
                    sortMatch.Selected = true;
                }
            }
            catch (Exception ex)
            {
                ShowError(DbHelper.FriendlyError(ex));
            }
        }

        /// <summary>
        /// Queries the items for the selected category/sort and binds one page of cards.
        /// </summary>
        private void LoadItems()
        {
            try
            {
                string category = Request.QueryString["category"] ?? "All";
                string sort = Request.QueryString["sort"] ?? "newest";

                string sql = @"SELECT ItemID, ItemName, Description, Category, Location, DateReported, Status, ImagePath
                               FROM dbo.Items";

                List<SqlParameter> parameters = new List<SqlParameter>();

                if (!string.IsNullOrEmpty(category) && !string.Equals(category, "All", StringComparison.OrdinalIgnoreCase))
                {
                    sql += " WHERE Category = @Category";
                    parameters.Add(new SqlParameter("@Category", SqlDbType.NVarChar, 50) { Value = category });
                }

                switch (sort)
                {
                    case "oldest":
                        sql += " ORDER BY DateReported ASC, ItemID ASC";
                        break;
                    case "name":
                        sql += " ORDER BY ItemName ASC";
                        break;
                    default:
                        sql += " ORDER BY DateReported DESC, ItemID DESC";
                        break;
                }

                DataTable items = DbHelper.ExecuteQuery(sql, parameters.ToArray());

                // Work out which page to show (1-based in the URL, 0-based for PagedDataSource).
                int totalPages = (int)Math.Ceiling(items.Rows.Count / (double)PageSize);
                if (totalPages < 1)
                {
                    totalPages = 1;
                }

                int pageNumber = 1;
                int requested;
                if (int.TryParse(Request.QueryString["page"], out requested))
                {
                    pageNumber = Math.Min(Math.Max(requested, 1), totalPages);
                }

                PagedDataSource paged = new PagedDataSource();
                paged.DataSource = items.DefaultView;
                paged.AllowPaging = true;
                paged.PageSize = PageSize;
                paged.CurrentPageIndex = pageNumber - 1;

                rptItems.DataSource = paged;
                rptItems.DataBind();

                pnlEmpty.Visible = items.Rows.Count == 0;

                if (items.Rows.Count == 0)
                {
                    litSummary.Text = "No items to show.";
                }
                else
                {
                    int first = (pageNumber - 1) * PageSize + 1;
                    int last = Math.Min(pageNumber * PageSize, items.Rows.Count);
                    litSummary.Text = string.Format("Showing {0}-{1} of {2} item(s).", first, last, items.Rows.Count);
                }

                litPager.Text = BuildPager(pageNumber, totalPages, category, sort);
            }
            catch (Exception ex)
            {
                ShowError(DbHelper.FriendlyError(ex));
                pnlEmpty.Visible = false;
            }
        }

        /// <summary>
        /// Creates the page-number links as plain HTML so the current filter survives paging.
        /// </summary>
        private string BuildPager(int currentPage, int totalPages, string category, string sort)
        {
            if (totalPages <= 1)
            {
                return string.Empty;
            }

            StringBuilder html = new StringBuilder();
            html.Append("<nav class=\"pager\" aria-label=\"Item pages\">");

            if (currentPage > 1)
            {
                html.AppendFormat("<a href=\"{0}\" aria-label=\"Previous page\">&laquo;</a>", BuildUrl(currentPage - 1, category, sort));
            }

            for (int page = 1; page <= totalPages; page++)
            {
                if (page == currentPage)
                {
                    html.AppendFormat("<span class=\"pager-current\" aria-current=\"page\">{0}</span>", page);
                }
                else
                {
                    html.AppendFormat("<a href=\"{0}\">{1}</a>", BuildUrl(page, category, sort), page);
                }
            }

            if (currentPage < totalPages)
            {
                html.AppendFormat("<a href=\"{0}\" aria-label=\"Next page\">&raquo;</a>", BuildUrl(currentPage + 1, category, sort));
            }

            html.Append("</nav>");
            return html.ToString();
        }

        /// <summary>
        /// Builds a safe Items.aspx URL for one page of results.
        /// </summary>
        private string BuildUrl(int page, string category, string sort)
        {
            return string.Format("Items.aspx?category={0}&amp;sort={1}&amp;page={2}",
                HttpUtility.UrlEncode(category ?? "All"),
                HttpUtility.UrlEncode(sort ?? "newest"),
                page);
        }

        /// <summary>
        /// Reloads the list with the newly selected category (always back to page 1).
        /// </summary>
        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildRedirectUrl(page: 1));
        }

        /// <summary>
        /// Reloads the list with the newly selected sort order.
        /// </summary>
        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildRedirectUrl(page: 1));
        }

        /// <summary>
        /// Builds the redirect URL from the current dropdown values.
        /// </summary>
        private string BuildRedirectUrl(int page)
        {
            return string.Format("Items.aspx?category={0}&sort={1}&page={2}",
                HttpUtility.UrlEncode(ddlCategory.SelectedValue),
                HttpUtility.UrlEncode(ddlSort.SelectedValue),
                page);
        }

        /// <summary>
        /// Shows a friendly error strip above the grid.
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
