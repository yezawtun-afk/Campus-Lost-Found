using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web.UI.WebControls;

namespace CampusLostFound
{
    /// <summary>
    /// Admin / data-entry page: add items, edit them inline, change status quickly and delete records.
    /// </summary>
    public partial class Admin : System.Web.UI.Page
    {
        // Largest photo we accept, in bytes (4 MB).
        private const int MaxImageBytes = 4 * 1024 * 1024;

        /// <summary>
        /// The column currently used to sort the grid (stored in ViewState).
        /// </summary>
        private string SortColumn
        {
            get { return Convert.ToString(ViewState["SortColumn"] ?? "DateReported"); }
            set { ViewState["SortColumn"] = value; }
        }

        /// <summary>
        /// The current sort direction: ASC or DESC.
        /// </summary>
        private string SortDirection
        {
            get { return Convert.ToString(ViewState["SortDirection"] ?? "DESC"); }
            set { ViewState["SortDirection"] = value; }
        }

        /// <summary>
        /// Sets the default date and loads the grid the first time the page is shown.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtNewDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                BindGrid();
            }
        }

        /// <summary>
        /// Reads every item and binds it to the GridView using the current sort order.
        /// </summary>
        private void BindGrid()
        {
            try
            {
                DataTable items = DbHelper.ExecuteQuery(
                    @"SELECT ItemID, ItemName, Description, Category, Location, DateReported, Status, ImagePath, ContactInfo
                      FROM dbo.Items");

                DataView view = items.DefaultView;
                view.Sort = SortColumn + " " + SortDirection;

                gvItems.DataSource = view;
                gvItems.DataBind();

                litGridSummary.Text = string.Format("{0} item(s) in total.", items.Rows.Count);
            }
            catch (Exception ex)
            {
                ShowMessage(DbHelper.FriendlyError(ex), false);
            }
        }

        /// <summary>
        /// Adds a new item from the quick-entry form (with an optional photo upload).
        /// </summary>
        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(txtNewName.Text) ||
                    string.IsNullOrWhiteSpace(txtNewLocation.Text) ||
                    string.IsNullOrEmpty(ddlNewCategory.SelectedValue))
                {
                    ShowMessage("Please fill in the item name, location and category.", false);
                    return;
                }

                DateTime dateReported;
                if (!DateTime.TryParse(txtNewDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out dateReported)
                    && !DateTime.TryParse(txtNewDate.Text, out dateReported))
                {
                    ShowMessage("Please choose a valid date reported.", false);
                    return;
                }

                if (dateReported.Date > DateTime.Today)
                {
                    ShowMessage("The date reported cannot be in the future.", false);
                    return;
                }

                string imagePath = null;

                if (fuNewImage.HasFile)
                {
                    string uploadError;
                    imagePath = SaveUploadedImage(fuNewImage, out uploadError);
                    if (uploadError != null)
                    {
                        ShowMessage(uploadError, false);
                        return;
                    }
                }
                else if (!string.IsNullOrWhiteSpace(txtNewImagePath.Text))
                {
                    imagePath = txtNewImagePath.Text.Trim();
                }

                const string sql =
                    @"INSERT INTO dbo.Items (ItemName, Description, Category, Location, DateReported, Status, ImagePath, ContactInfo)
                      VALUES (@ItemName, @Description, @Category, @Location, @DateReported, @Status, @ImagePath, @ContactInfo)";

                DbHelper.ExecuteNonQuery(sql,
                    new SqlParameter("@ItemName", SqlDbType.NVarChar, 100) { Value = txtNewName.Text.Trim() },
                    new SqlParameter("@Description", SqlDbType.NVarChar, 500) { Value = Nullable(txtNewDescription.Text) },
                    new SqlParameter("@Category", SqlDbType.NVarChar, 50) { Value = ddlNewCategory.SelectedValue },
                    new SqlParameter("@Location", SqlDbType.NVarChar, 100) { Value = txtNewLocation.Text.Trim() },
                    new SqlParameter("@DateReported", SqlDbType.Date) { Value = dateReported.Date },
                    new SqlParameter("@Status", SqlDbType.NVarChar, 20) { Value = ddlNewStatus.SelectedValue },
                    new SqlParameter("@ImagePath", SqlDbType.NVarChar, 200) { Value = (object)imagePath ?? DBNull.Value },
                    new SqlParameter("@ContactInfo", SqlDbType.NVarChar, 100) { Value = Nullable(txtNewContact.Text) });

                ClearAddForm();
                BindGrid();
                ShowMessage("New item added successfully.", true);
            }
            catch (Exception ex)
            {
                ShowMessage(DbHelper.FriendlyError(ex), false);
            }
        }

        /// <summary>
        /// Clears the quick-entry form and puts the date back to today.
        /// </summary>
        protected void btnClearAdd_Click(object sender, EventArgs e)
        {
            ClearAddForm();
        }

        /// <summary>
        /// Puts one row into edit mode.
        /// </summary>
        protected void gvItems_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvItems.EditIndex = e.NewEditIndex;
            BindGrid();
        }

        /// <summary>
        /// Cancels inline editing.
        /// </summary>
        protected void gvItems_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvItems.EditIndex = -1;
            BindGrid();
        }

        /// <summary>
        /// Saves the values typed into a row's edit controls.
        /// </summary>
        protected void gvItems_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            try
            {
                int itemId = Convert.ToInt32(gvItems.DataKeys[e.RowIndex].Value);
                GridViewRow row = gvItems.Rows[e.RowIndex];

                TextBox nameBox = (TextBox)row.FindControl("txtEditName");
                TextBox descriptionBox = (TextBox)row.FindControl("txtEditDescription");
                DropDownList categoryBox = (DropDownList)row.FindControl("ddlEditCategory");
                TextBox locationBox = (TextBox)row.FindControl("txtEditLocation");
                DropDownList statusBox = (DropDownList)row.FindControl("ddlEditStatus");
                TextBox contactBox = (TextBox)row.FindControl("txtEditContact");

                if (nameBox == null || string.IsNullOrWhiteSpace(nameBox.Text))
                {
                    ShowMessage("The item name cannot be empty.", false);
                    return;
                }

                if (locationBox == null || string.IsNullOrWhiteSpace(locationBox.Text))
                {
                    ShowMessage("The location cannot be empty.", false);
                    return;
                }

                const string sql =
                    @"UPDATE dbo.Items
                      SET ItemName = @ItemName,
                          Description = @Description,
                          Category = @Category,
                          Location = @Location,
                          Status = @Status,
                          ContactInfo = @ContactInfo
                      WHERE ItemID = @ItemID";

                DbHelper.ExecuteNonQuery(sql,
                    new SqlParameter("@ItemName", SqlDbType.NVarChar, 100) { Value = nameBox.Text.Trim() },
                    new SqlParameter("@Description", SqlDbType.NVarChar, 500) { Value = Nullable(descriptionBox.Text) },
                    new SqlParameter("@Category", SqlDbType.NVarChar, 50) { Value = categoryBox.SelectedValue },
                    new SqlParameter("@Location", SqlDbType.NVarChar, 100) { Value = locationBox.Text.Trim() },
                    new SqlParameter("@Status", SqlDbType.NVarChar, 20) { Value = statusBox.SelectedValue },
                    new SqlParameter("@ContactInfo", SqlDbType.NVarChar, 100) { Value = Nullable(contactBox.Text) },
                    new SqlParameter("@ItemID", SqlDbType.Int) { Value = itemId });

                gvItems.EditIndex = -1;
                BindGrid();
                ShowMessage("Item updated successfully.", true);
            }
            catch (Exception ex)
            {
                ShowMessage(DbHelper.FriendlyError(ex), false);
            }
        }

        /// <summary>
        /// Deletes a row; the FK cascade also removes its Reports rows.
        /// </summary>
        protected void gvItems_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            try
            {
                int itemId = Convert.ToInt32(gvItems.DataKeys[e.RowIndex].Value);

                int removed = DbHelper.ExecuteNonQuery(
                    "DELETE FROM dbo.Items WHERE ItemID = @ItemID",
                    new SqlParameter("@ItemID", SqlDbType.Int) { Value = itemId });

                gvItems.EditIndex = -1;
                BindGrid();

                if (removed > 0)
                {
                    ShowMessage("Item deleted successfully, including its report rows.", true);
                }
                else
                {
                    ShowMessage("That item could not be found - it may already be deleted.", false);
                }
            }
            catch (Exception ex)
            {
                ShowMessage(DbHelper.FriendlyError(ex), false);
            }
        }

        /// <summary>
        /// Moves the grid to another page of rows.
        /// </summary>
        protected void gvItems_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvItems.PageIndex = e.NewPageIndex;
            BindGrid();
        }

        /// <summary>
        /// Sorts the grid by the clicked column, toggling direction on repeat clicks.
        /// </summary>
        protected void gvItems_Sorting(object sender, GridViewSortEventArgs e)
        {
            if (string.Equals(SortColumn, e.SortExpression, StringComparison.OrdinalIgnoreCase))
            {
                SortDirection = SortDirection == "ASC" ? "DESC" : "ASC";
            }
            else
            {
                SortColumn = e.SortExpression;
                SortDirection = "ASC";
            }

            gvItems.PageIndex = 0;
            BindGrid();
        }

        /// <summary>
        /// One-click status change from the dropdown inside each row.
        /// </summary>
        protected void StatusChanged(object sender, EventArgs e)
        {
            try
            {
                DropDownList list = (DropDownList)sender;
                GridViewRow row = (GridViewRow)list.NamingContainer;
                int itemId = Convert.ToInt32(gvItems.DataKeys[row.RowIndex].Value);
                string newStatus = list.SelectedValue;

                DbHelper.ExecuteNonQuery(
                    "UPDATE dbo.Items SET Status = @Status WHERE ItemID = @ItemID",
                    new SqlParameter("@Status", SqlDbType.NVarChar, 20) { Value = newStatus },
                    new SqlParameter("@ItemID", SqlDbType.Int) { Value = itemId });

                BindGrid();
                ShowMessage(string.Format("Status updated to \"{0}\".", newStatus), true);
            }
            catch (Exception ex)
            {
                ShowMessage(DbHelper.FriendlyError(ex), false);
            }
        }

        /// <summary>
        /// Saves an uploaded image into Images/items and returns its virtual path.
        /// Sets errMsg when the file type or size is not allowed.
        /// </summary>
        private string SaveUploadedImage(FileUpload upload, out string errMsg)
        {
            errMsg = null;

            string extension = Path.GetExtension(upload.FileName).ToLowerInvariant();
            if (extension == ".jpeg")
            {
                extension = ".jpg";
            }

            if (extension != ".jpg" && extension != ".png")
            {
                errMsg = "The photo must be a JPG or PNG file.";
                return null;
            }

            if (upload.PostedFile.ContentLength <= 0 || upload.PostedFile.ContentLength > MaxImageBytes)
            {
                errMsg = "The photo must be smaller than 4 MB.";
                return null;
            }

            string folder = Server.MapPath("~/Images/items/");
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }

            string fileName = "item-" + Guid.NewGuid().ToString("N") + extension;
            upload.SaveAs(Path.Combine(folder, fileName));

            return "~/Images/items/" + fileName;
        }

        /// <summary>
        /// Resets every field in the quick-entry form.
        /// </summary>
        private void ClearAddForm()
        {
            txtNewName.Text = string.Empty;
            txtNewDescription.Text = string.Empty;
            txtNewLocation.Text = string.Empty;
            txtNewContact.Text = string.Empty;
            txtNewImagePath.Text = string.Empty;
            ddlNewCategory.SelectedIndex = 0;
            ddlNewStatus.SelectedIndex = 0;
            txtNewDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }

        /// <summary>
        /// Shows the shared message strip in green (success) or red (error).
        /// </summary>
        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "alert alert-success" : "alert alert-error";
            litMessage.Text = Server.HtmlEncode(message);
        }

        /// <summary>
        /// Turns an empty textbox into DBNull so the database stores NULL instead of "".
        /// </summary>
        private static object Nullable(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value.Trim();
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
