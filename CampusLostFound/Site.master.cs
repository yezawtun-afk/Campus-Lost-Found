using System;
using System.IO;

namespace CampusLostFound
{
    /// <summary>
    /// Shared master page: renders the header, navigation and footer for every page.
    /// </summary>
    public partial class SiteMaster : System.Web.UI.MasterPage
    {
        /// <summary>
        /// Current year, used in the footer copyright line.
        /// </summary>
        protected string Year
        {
            get { return DateTime.Now.Year.ToString(); }
        }

        /// <summary>
        /// Cache-busting value for Site.css: changes whenever the file is edited,
        /// so the browser always picks up the latest styles.
        /// </summary>
        protected string CssVersion
        {
            get
            {
                string physicalPath = Server.MapPath("~/Content/Site.css");
                return File.Exists(physicalPath)
                    ? File.GetLastWriteTimeUtc(physicalPath).Ticks.ToString()
                    : "1";
            }
        }

        /// <summary>
        /// Returns the CSS class for a nav link, adding "is-active" when the
        /// requested page is the one currently being viewed.
        /// </summary>
        protected string NavClass(string pageFileName)
        {
            string currentPage = Path.GetFileName(Request.AppRelativeCurrentExecutionFilePath);
            bool isActive = string.Equals(currentPage, pageFileName, StringComparison.OrdinalIgnoreCase);
            return isActive ? "nav-link is-active" : "nav-link";
        }

        /// <summary>
        /// Returns the CSS class for the filled "Report Item" navigation action,
        /// adding "is-active" when the report page is being viewed.
        /// </summary>
        protected string NavActionClass(string pageFileName)
        {
            string currentPage = Path.GetFileName(Request.AppRelativeCurrentExecutionFilePath);
            bool isActive = string.Equals(currentPage, pageFileName, StringComparison.OrdinalIgnoreCase);
            return isActive ? "nav-action is-active" : "nav-action";
        }
    }
}
