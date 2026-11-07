<%@ Page Title="Report Item" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Report.aspx.cs" Inherits="CampusLostFound.Report" %>

<asp:Content ID="MainContentBlock" ContentPlaceHolderID="MainContent" runat="server">

    <header class="page-header page-header--coral">
        <div class="container">
            <div class="page-header-crumbs">
                <a href="<%= ResolveUrl("~/Default.aspx") %>">Home</a>
                <span aria-hidden="true">/</span>
                <span>Report Item</span>
            </div>
            <h1>Tell us what you lost or found</h1>
            <p>One form for both report types. Your entry appears on the register straight away and is reviewed by the Security Office.</p>
        </div>
    </header>

    <section class="chapter chapter--paper">
        <div class="container">
            <div class="split">

                <!-- Main form -->
                <div class="form-card">

                    <!-- Success message shown after a saved report -->
                    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success" role="status">
                        <div>
                            <asp:Literal ID="litSuccess" runat="server" />
                            <div class="btn-row" style="margin-top:14px;">
                                <a class="btn btn-sm btn-ink" href="<%= ResolveUrl("~/Items.aspx") %>">View the register</a>
                                <a class="btn btn-sm btn-outline" href="<%= ResolveUrl("~/Report.aspx") %>">Report another item</a>
                            </div>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                        <asp:Literal ID="litError" runat="server" />
                    </asp:Panel>

                    <asp:ValidationSummary ID="vsSummary" runat="server"
                        CssClass="validation-summary-errors"
                        DisplayMode="BulletList"
                        HeaderText="Please check the highlighted fields:"
                        ShowMessageBox="false"
                        ShowSummary="true" />

                    <div class="form-grid">

                        <div class="form-group">
                            <label class="form-label" for="<%= txtFullName.ClientID %>">Full name <span class="req">*</span></label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="100" placeholder="e.g. Aisha Rahman" />
                            <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
                                ErrorMessage="Please enter your full name." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="<%= txtStudentId.ClientID %>">Student / staff ID <span class="req">*</span></label>
                            <asp:TextBox ID="txtStudentId" runat="server" CssClass="form-control" MaxLength="30" placeholder="e.g. STU2023-0412" />
                            <asp:RequiredFieldValidator ID="rfvStudentId" runat="server" ControlToValidate="txtStudentId"
                                ErrorMessage="Please enter your student or staff ID." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group span-2">
                            <label class="form-label" for="<%= txtItemName.ClientID %>">Item name <span class="req">*</span></label>
                            <asp:TextBox ID="txtItemName" runat="server" CssClass="form-control" MaxLength="100" placeholder="e.g. Brown Leather Wallet" />
                            <asp:RequiredFieldValidator ID="rfvItemName" runat="server" ControlToValidate="txtItemName"
                                ErrorMessage="Please enter the item name." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group span-2">
                            <label class="form-label" for="<%= txtDescription.ClientID %>">Description <span class="req">*</span></label>
                            <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine"
                                MaxLength="500" placeholder="Colour, brand, size and any marks that make the item easy to identify." />
                            <span class="form-hint">Up to 500 characters. Leave out one detail if you found the item - it helps us check the owner.</span>
                            <asp:RequiredFieldValidator ID="rfvDescription" runat="server" ControlToValidate="txtDescription"
                                ErrorMessage="Please describe the item." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="<%= ddlCategory.ClientID %>">Category <span class="req">*</span></label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                                <asp:ListItem Value="" Text="Select a category..." />
                                <asp:ListItem Value="Electronic Devices" Text="Electronic Devices" />
                                <asp:ListItem Value="Books" Text="Books" />
                                <asp:ListItem Value="Student Cards" Text="Student Cards" />
                                <asp:ListItem Value="Personal Belongings" Text="Personal Belongings" />
                                <asp:ListItem Value="Accessories" Text="Accessories" />
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvCategory" runat="server" ControlToValidate="ddlCategory"
                                InitialValue="" ErrorMessage="Please choose a category." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="<%= txtLocation.ClientID %>">Location <span class="req">*</span></label>
                            <asp:TextBox ID="txtLocation" runat="server" CssClass="form-control" MaxLength="100" placeholder="e.g. Library - 2nd Floor" />
                            <asp:RequiredFieldValidator ID="rfvLocation" runat="server" ControlToValidate="txtLocation"
                                ErrorMessage="Please enter the location." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="<%= txtDate.ClientID %>">Date reported <span class="req">*</span></label>
                            <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" TextMode="Date" />
                            <asp:RequiredFieldValidator ID="rfvDate" runat="server" ControlToValidate="txtDate"
                                ErrorMessage="Please choose the date." CssClass="field-error" Display="Dynamic" />
                            <asp:CustomValidator ID="cvDate" runat="server" ControlToValidate="txtDate"
                                ErrorMessage="The date cannot be in the future." CssClass="field-error" Display="Dynamic"
                                OnServerValidate="cvDate_ServerValidate" ValidateEmptyText="false" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Report type <span class="req">*</span></label>
                            <asp:RadioButtonList ID="rblReportType" runat="server" CssClass="radio-list"
                                RepeatLayout="UnorderedList" RepeatDirection="Vertical">
                                <asp:ListItem Value="Lost" Text="I lost this item" />
                                <asp:ListItem Value="Found" Text="I found this item" />
                            </asp:RadioButtonList>
                            <asp:RequiredFieldValidator ID="rfvReportType" runat="server" ControlToValidate="rblReportType"
                                ErrorMessage="Please choose Lost or Found." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="<%= txtContact.ClientID %>">Contact information <span class="req">*</span></label>
                            <asp:TextBox ID="txtContact" runat="server" CssClass="form-control" MaxLength="100" placeholder="Email address or phone number" />
                            <span class="form-hint">Used only by the Security Office to contact you about this item.</span>
                            <asp:RequiredFieldValidator ID="rfvContact" runat="server" ControlToValidate="txtContact"
                                ErrorMessage="Please leave an email address or phone number." CssClass="field-error" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revContact" runat="server" ControlToValidate="txtContact"
                                ValidationExpression="^([A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}|[+0-9][0-9 ()\-]{6,19})$"
                                ErrorMessage="Enter a valid email address or phone number." CssClass="field-error" Display="Dynamic" />
                        </div>

                        <div class="form-group span-2">
                            <label class="form-label" for="<%= fuImage.ClientID %>">Photo (optional)</label>
                            <asp:FileUpload ID="fuImage" runat="server" CssClass="form-control" accept=".jpg,.jpeg,.png" />
                            <span class="form-hint">JPG or PNG only, up to 4 MB. A photo makes it much easier to identify the item.</span>
                            <asp:CustomValidator ID="cvImage" runat="server"
                                ErrorMessage="The photo must be a JPG or PNG file smaller than 4 MB."
                                CssClass="field-error" Display="Dynamic"
                                OnServerValidate="cvImage_ServerValidate" />
                        </div>
                    </div>

                    <div class="form-actions">
                        <asp:Button ID="btnSubmit" runat="server" Text="Submit report" CssClass="btn btn-primary"
                            OnClick="btnSubmit_Click" />
                        <a class="btn btn-outline" href="<%= ResolveUrl("~/Items.aspx") %>">Browse items instead</a>
                    </div>
                </div>

                <!-- Sidebar help -->
                <aside class="report-aside">
                    <div class="card card-body">
                        <h3>Before you submit</h3>
                        <ul>
                            <li>Check the register first - your item may already be there.</li>
                            <li>Describe marks, stickers or engravings that prove ownership.</li>
                            <li>Found an item? Hand it to the Security Office before reporting.</li>
                            <li>Use a contact address you check daily.</li>
                        </ul>
                    </div>

                    <div class="card card-body card--ink">
                        <h3>Security Office</h3>
                        <p>Block A, Ground Floor<br />Mon - Fri, 8:00 a.m. - 5:30 p.m.</p>
                        <p style="margin:0;"><a href="mailto:security.office@campus.edu">security.office@campus.edu</a></p>
                    </div>
                </aside>

            </div>
        </div>
    </section>

</asp:Content>
