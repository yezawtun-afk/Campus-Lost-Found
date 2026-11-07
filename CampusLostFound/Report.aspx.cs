using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Web.UI.WebControls;

namespace CampusLostFound
{
    /// <summary>
    /// Report Item page: validates the form, optionally saves a photo, and writes the
    /// Items + Reports rows inside a single transaction.
    /// </summary>
    public partial class Report : System.Web.UI.Page
    {
        // Largest photo we accept, in bytes (4 MB).
        private const int MaxImageBytes = 4 * 1024 * 1024;

        /// <summary>
        /// Prepares the form: multipart encoding for the upload, today's date and the
        /// report type taken from the ?type= query string.
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // A file upload only works when the form posts as multipart/form-data.
            if (Page.Form != null)
            {
                Page.Form.Enctype = "multipart/form-data";
            }

            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

                string type = Request.QueryString["type"];
                if (string.Equals(type, "Found", StringComparison.OrdinalIgnoreCase))
                {
                    rblReportType.SelectedValue = "Found";
                }
                else if (string.Equals(type, "Lost", StringComparison.OrdinalIgnoreCase))
                {
                    rblReportType.SelectedValue = "Lost";
                }
            }
        }

        /// <summary>
        /// Checks that the chosen date is a real date and not in the future.
        /// </summary>
        protected void cvDate_ServerValidate(object source, ServerValidateEventArgs args)
        {
            DateTime parsed;
            bool isValidDate = DateTime.TryParse(args.Value, CultureInfo.InvariantCulture, DateTimeStyles.None, out parsed)
                               || DateTime.TryParse(args.Value, out parsed);

            args.IsValid = isValidDate && parsed.Date <= DateTime.Today;
        }

        /// <summary>
        /// Checks the optional photo: JPG or PNG only, and no larger than 4 MB.
        /// </summary>
        protected void cvImage_ServerValidate(object source, ServerValidateEventArgs args)
        {
            if (!fuImage.HasFile)
            {
                args.IsValid = true;
                return;
            }

            string extension = Path.GetExtension(fuImage.FileName).ToLowerInvariant();
            bool allowedType = extension == ".jpg" || extension == ".jpeg" || extension == ".png";

            args.IsValid = allowedType && fuImage.PostedFile.ContentLength > 0
                           && fuImage.PostedFile.ContentLength <= MaxImageBytes;
        }

        /// <summary>
        /// Saves the item and its reporter row in one transaction, then clears the form.
        /// </summary>
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            pnlError.Visible = false;
            pnlSuccess.Visible = false;

            if (!Page.IsValid)
            {
                return;
            }

            string savedImagePath = null;

            try
            {
                // 1. Save the optional photo to ~/Images/items with a unique file name.
                if (fuImage.HasFile)
                {
                    string extension = Path.GetExtension(fuImage.FileName).ToLowerInvariant();
                    if (extension == ".jpeg")
                    {
                        extension = ".jpg";
                    }

                    string folder = Server.MapPath("~/Images/items/");
                    if (!Directory.Exists(folder))
                    {
                        Directory.CreateDirectory(folder);
                    }

                    string fileName = "item-" + Guid.NewGuid().ToString("N") + extension;
                    fuImage.SaveAs(Path.Combine(folder, fileName));
                    savedImagePath = "~/Images/items/" + fileName;
                }

                // 2. Insert Items + Reports inside one transaction (rollback on any failure).
                using (SqlConnection connection = DbHelper.GetConnection())
                using (SqlTransaction transaction = connection.BeginTransaction())
                {
                    try
                    {
                        const string insertItemSql =
                            @"INSERT INTO dbo.Items (ItemName, Description, Category, Location, DateReported, Status, ImagePath, ContactInfo)
                              VALUES (@ItemName, @Description, @Category, @Location, @DateReported, @Status, @ImagePath, @ContactInfo);
                              SELECT CAST(SCOPE_IDENTITY() AS INT);";

                        int newItemId;

                        using (SqlCommand command = new SqlCommand(insertItemSql, connection, transaction))
                        {
                            command.Parameters.Add(new SqlParameter("@ItemName", SqlDbType.NVarChar, 100) { Value = txtItemName.Text.Trim() });
                            command.Parameters.Add(new SqlParameter("@Description", SqlDbType.NVarChar, 500) { Value = txtDescription.Text.Trim() });
                            command.Parameters.Add(new SqlParameter("@Category", SqlDbType.NVarChar, 50) { Value = ddlCategory.SelectedValue });
                            command.Parameters.Add(new SqlParameter("@Location", SqlDbType.NVarChar, 100) { Value = txtLocation.Text.Trim() });
                            command.Parameters.Add(new SqlParameter("@DateReported", SqlDbType.Date) { Value = DateTime.Parse(txtDate.Text).Date });
                            command.Parameters.Add(new SqlParameter("@Status", SqlDbType.NVarChar, 20) { Value = rblReportType.SelectedValue });
                            command.Parameters.Add(new SqlParameter("@ImagePath", SqlDbType.NVarChar, 200)
                            {
                                Value = (object)savedImagePath ?? DBNull.Value
                            });
                            command.Parameters.Add(new SqlParameter("@ContactInfo", SqlDbType.NVarChar, 100) { Value = txtContact.Text.Trim() });

                            newItemId = Convert.ToInt32(command.ExecuteScalar());
                        }

                        const string insertReportSql =
                            @"INSERT INTO dbo.Reports (ItemID, ReporterName, StudentStaffID, ReportType, ReportDate)
                              VALUES (@ItemID, @ReporterName, @StudentStaffID, @ReportType, @ReportDate);";

                        using (SqlCommand command = new SqlCommand(insertReportSql, connection, transaction))
                        {
                            command.Parameters.Add(new SqlParameter("@ItemID", SqlDbType.Int) { Value = newItemId });
                            command.Parameters.Add(new SqlParameter("@ReporterName", SqlDbType.NVarChar, 100) { Value = txtFullName.Text.Trim() });
                            command.Parameters.Add(new SqlParameter("@StudentStaffID", SqlDbType.NVarChar, 30) { Value = txtStudentId.Text.Trim() });
                            command.Parameters.Add(new SqlParameter("@ReportType", SqlDbType.NVarChar, 10) { Value = rblReportType.SelectedValue });
                            command.Parameters.Add(new SqlParameter("@ReportDate", SqlDbType.Date) { Value = DateTime.Parse(txtDate.Text).Date });

                            command.ExecuteNonQuery();
                        }

                        transaction.Commit();

                        ShowSuccess(rblReportType.SelectedValue);
                        ClearForm();
                    }
                    catch
                    {
                        // Undo both inserts so the register never holds half a record.
                        try { transaction.Rollback(); }
                        catch { /* the connection is already closing - nothing more to do */ }
                        throw;
                    }
                }
            }
            catch (Exception ex)
            {
                // Remove an orphaned upload so the folder stays tidy.
                if (!string.IsNullOrEmpty(savedImagePath))
                {
                    try
                    {
                        string orphan = Server.MapPath(savedImagePath);
                        if (File.Exists(orphan))
                        {
                            File.Delete(orphan);
                        }
                    }
                    catch { /* ignore clean-up problems */ }
                }

                ShowError(DbHelper.FriendlyError(ex));
            }
        }

        /// <summary>
        /// Shows the green success panel with a short confirmation of what was saved.
        /// </summary>
        private void ShowSuccess(string reportType)
        {
            string message = string.Format(
                "Your item has been successfully reported. A \"{0}\" record now appears on the register for \"{1}\".",
                Server.HtmlEncode(reportType),
                Server.HtmlEncode(txtItemName.Text.Trim()));

            litSuccess.Text = message;
            pnlSuccess.Visible = true;
            pnlSuccess.Focus();
        }

        /// <summary>
        /// Shows the red error panel with a friendly message (never a raw exception).
        /// </summary>
        private void ShowError(string message)
        {
            litError.Text = Server.HtmlEncode(message);
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
        }

        /// <summary>
        /// Clears every field and returns the form to its default state.
        /// </summary>
        private void ClearForm()
        {
            txtFullName.Text = string.Empty;
            txtStudentId.Text = string.Empty;
            txtItemName.Text = string.Empty;
            txtDescription.Text = string.Empty;
            txtLocation.Text = string.Empty;
            txtContact.Text = string.Empty;

            ddlCategory.SelectedIndex = 0;
            rblReportType.ClearSelection();

            txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            fuImage.Dispose();
        }
    }
}
