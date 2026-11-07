using System;

namespace CampusLostFound
{
    /// <summary>
    /// Friendly error page shown by the customErrors setting in Web.config.
    /// It never displays exception details to the visitor.
    /// </summary>
    public partial class ErrorPage : System.Web.UI.Page
    {
        /// <summary>
        /// Page load - the page is static, so no work is required.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
