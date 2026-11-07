using System;
using System.Data;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace CampusLostFound
{
    /// <summary>
    /// Home page: hero banner, headline statistics and the four most recent items.
    /// </summary>
    public partial class Home : System.Web.UI.Page
    {
        /// <summary>
        /// Loads the statistics and the latest four items when the page is shown.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStatistics();
                LoadRecentItems();
            }
        }

        /// <summary>
        /// Fills the three hero numbers (total, waiting to be claimed, returned).
        /// </summary>
        private void LoadStatistics()
        {
            try
            {
                DataTable summary = DbHelper.ExecuteQuery(
                    @"SELECT
                          (SELECT COUNT(*) FROM dbo.Items) AS TotalItems,
                          (SELECT COUNT(*) FROM dbo.Items WHERE Status = 'Found') AS FoundItems,
                          (SELECT COUNT(*) FROM dbo.Items WHERE Status = 'Claimed') AS ClaimedItems");

                if (summary.Rows.Count > 0)
                {
                    litTotal.Text = Convert.ToInt32(summary.Rows[0]["TotalItems"]).ToString();
                    litFound.Text = Convert.ToInt32(summary.Rows[0]["FoundItems"]).ToString();
                    litClaimed.Text = Convert.ToInt32(summary.Rows[0]["ClaimedItems"]).ToString();
                }
            }
            catch (Exception ex)
            {
                ShowError(DbHelper.FriendlyError(ex));
            }
        }

        /// <summary>
        /// Binds the four newest items to the "Recently reported" repeater.
        /// </summary>
        private void LoadRecentItems()
        {
            try
            {
                DataTable items = DbHelper.ExecuteQuery(
                    @"SELECT TOP 4 ItemID, ItemName, Description, Category, Location, DateReported, Status, ImagePath
                      FROM dbo.Items
                      ORDER BY DateReported DESC, ItemID DESC");

                rptRecent.DataSource = items;
                rptRecent.DataBind();
            }
            catch (Exception ex)
            {
                ShowError(DbHelper.FriendlyError(ex));
            }
        }

        /// <summary>
        /// Shows a friendly error strip and hides the repeater content.
        /// </summary>
        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = Server.HtmlEncode(message);
        }

        /// <summary>
        /// Returns a usable image URL: the stored path if the file exists, otherwise the placeholder.
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
        /// Returns "badge badge-lost", "badge badge-found" or "badge badge-claimed" for the status.
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
