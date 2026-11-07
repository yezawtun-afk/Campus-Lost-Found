<%@ Page Title="Admin" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="CampusLostFound.Admin" %>

<asp:Content ID="MainContentBlock" ContentPlaceHolderID="MainContent" runat="server">

    <header class="page-header">
        <div class="container">
            <div class="page-header-crumbs">
                <a href="<%= ResolveUrl("~/Default.aspx") %>">Home</a>
                <span aria-hidden="true">/</span>
                <span>Admin</span>
            </div>
            <h1>Item administration</h1>
            <p>Add items, edit records, change a status in one click, or remove an item. Deleting an item also removes its report rows.</p>
        </div>
    </header>

    <section class="chapter chapter--paper">
        <div class="container">

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-info" role="status">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <!-- Add new item -->
            <div class="form-card">
                <h2 style="font-size:24px; margin-bottom:20px;">Add a new item</h2>

                <div class="form-grid">
                    <div class="form-group">
                        <label class="form-label" for="<%= txtNewName.ClientID %>">Item name <span class="req">*</span></label>
                        <asp:TextBox ID="txtNewName" runat="server" CssClass="form-control" MaxLength="100" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= txtNewLocation.ClientID %>">Location <span class="req">*</span></label>
                        <asp:TextBox ID="txtNewLocation" runat="server" CssClass="form-control" MaxLength="100" />
                    </div>

                    <div class="form-group span-2">
                        <label class="form-label" for="<%= txtNewDescription.ClientID %>">Description</label>
                        <asp:TextBox ID="txtNewDescription" runat="server" CssClass="form-control" TextMode="MultiLine" MaxLength="500"
                            style="min-height:90px;" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= ddlNewCategory.ClientID %>">Category <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlNewCategory" runat="server" CssClass="form-control">
                            <asp:ListItem Value="" Text="Select a category..." />
                            <asp:ListItem Value="Electronic Devices" Text="Electronic Devices" />
                            <asp:ListItem Value="Books" Text="Books" />
                            <asp:ListItem Value="Student Cards" Text="Student Cards" />
                            <asp:ListItem Value="Personal Belongings" Text="Personal Belongings" />
                            <asp:ListItem Value="Accessories" Text="Accessories" />
                        </asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= ddlNewStatus.ClientID %>">Status <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlNewStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="Lost" Text="Lost" />
                            <asp:ListItem Value="Found" Text="Found" />
                            <asp:ListItem Value="Claimed" Text="Claimed" />
                        </asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= txtNewDate.ClientID %>">Date reported <span class="req">*</span></label>
                        <asp:TextBox ID="txtNewDate" runat="server" CssClass="form-control" TextMode="Date" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= txtNewContact.ClientID %>">Contact information</label>
                        <asp:TextBox ID="txtNewContact" runat="server" CssClass="form-control" MaxLength="100" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= txtNewImagePath.ClientID %>">Image path (optional)</label>
                        <asp:TextBox ID="txtNewImagePath" runat="server" CssClass="form-control" MaxLength="200"
                            placeholder="~/Images/items/wallet1.jpg" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= fuNewImage.ClientID %>">...or upload a photo</label>
                        <asp:FileUpload ID="fuNewImage" runat="server" CssClass="form-control" accept=".jpg,.jpeg,.png" />
                        <span class="form-hint">JPG or PNG up to 4 MB. An upload replaces the image path above.</span>
                    </div>
                </div>

                <div class="form-actions">
                    <asp:Button ID="btnAddItem" runat="server" Text="Add item" CssClass="btn btn-primary" OnClick="btnAddItem_Click" />
                    <asp:Button ID="btnClearAdd" runat="server" Text="Clear form" CssClass="btn btn-outline"
                        OnClick="btnClearAdd_Click" CausesValidation="false" />
                </div>
            </div>

            <!-- Grid of all items -->
            <div class="section-head" style="margin-top:64px;">
                <div>
                    <h2>Items on the register</h2>
                    <p><asp:Literal ID="litGridSummary" runat="server" /></p>
                </div>
            </div>

            <div class="table-wrap">
                <asp:GridView ID="gvItems" runat="server"
                    CssClass="data-grid"
                    AutoGenerateColumns="false"
                    DataKeyNames="ItemID"
                    AllowSorting="true"
                    AllowPaging="true"
                    PageSize="8"
                    GridLines="None"
                    OnRowEditing="gvItems_RowEditing"
                    OnRowUpdating="gvItems_RowUpdating"
                    OnRowCancelingEdit="gvItems_RowCancelingEdit"
                    OnRowDeleting="gvItems_RowDeleting"
                    OnPageIndexChanging="gvItems_PageIndexChanging"
                    OnSorting="gvItems_Sorting">

                    <PagerStyle CssClass="grid-pager" HorizontalAlign="Left" />
                    <HeaderStyle CssClass="grid-head" />

                    <EmptyDataTemplate>
                        <div style="padding:2.5rem 1.5rem; text-align:center;">
                            <strong>No items yet.</strong>
                            <p class="muted" style="margin:0.35rem 0 0;">Use the form above to add the first record.</p>
                        </div>
                    </EmptyDataTemplate>

                    <Columns>
                        <asp:BoundField DataField="ItemID" HeaderText="ID"
                            SortExpression="ItemID" ReadOnly="true" ItemStyle-Width="56px" />

                        <asp:TemplateField HeaderText="Image" ItemStyle-Width="84px">
                            <ItemTemplate>
                                <img class="thumb" src='<%# ImageUrl(Eval("ImagePath")) %>' alt=""
                                     onerror="this.onerror=null;this.src='Images/placeholder.jpg';" />
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Name" SortExpression="ItemName" ItemStyle-Width="200px">
                            <ItemTemplate>
                                <strong><%# Eval("ItemName") %></strong>
                                <div class="row-note"><%# Eval("Description") %></div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditName" runat="server" Text='<%# Bind("ItemName") %>' MaxLength="100" />
                                <asp:TextBox ID="txtEditDescription" runat="server" TextMode="MultiLine"
                                    Text='<%# Bind("Description") %>' MaxLength="500" Style="margin-top:0.35rem;" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Category" SortExpression="Category" ItemStyle-Width="160px">
                            <ItemTemplate><%# Eval("Category") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditCategory" runat="server" SelectedValue='<%# Eval("Category") %>'>
                                    <asp:ListItem Value="Electronic Devices" Text="Electronic Devices" />
                                    <asp:ListItem Value="Books" Text="Books" />
                                    <asp:ListItem Value="Student Cards" Text="Student Cards" />
                                    <asp:ListItem Value="Personal Belongings" Text="Personal Belongings" />
                                    <asp:ListItem Value="Accessories" Text="Accessories" />
                                </asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Location" SortExpression="Location" ItemStyle-Width="140px">
                            <ItemTemplate><%# Eval("Location") %></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditLocation" runat="server" Text='<%# Bind("Location") %>' MaxLength="100" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="DateReported" HeaderText="Date" ReadOnly="true"
                            SortExpression="DateReported" DataFormatString="{0:dd MMM yyyy}" ItemStyle-Width="100px" />

                        <asp:TemplateField HeaderText="Status" SortExpression="Status" ItemStyle-Width="140px">
                            <ItemTemplate>
                                <span class='<%# StatusCss(Eval("Status")) %>'><%# Eval("Status") %></span>
                                <asp:DropDownList ID="ddlQuickStatus" runat="server" AutoPostBack="true"
                                    OnSelectedIndexChanged="StatusChanged" SelectedValue='<%# Eval("Status") %>'
                                    CssClass="form-control" style="margin-top:8px; padding:6px 8px; font-size:13px;">
                                    <asp:ListItem Value="Lost" Text="Lost" />
                                    <asp:ListItem Value="Found" Text="Found" />
                                    <asp:ListItem Value="Claimed" Text="Claimed" />
                                </asp:DropDownList>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:DropDownList ID="ddlEditStatus" runat="server" SelectedValue='<%# Eval("Status") %>'>
                                    <asp:ListItem Value="Lost" Text="Lost" />
                                    <asp:ListItem Value="Found" Text="Found" />
                                    <asp:ListItem Value="Claimed" Text="Claimed" />
                                </asp:DropDownList>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Contact">
                            <ItemTemplate><span class="muted" style="font-size:13px;" title='<%# Server.HtmlEncode(Convert.ToString(Eval("ContactInfo"))) %>'><%# Eval("ContactInfo") %></span></ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditContact" runat="server" Text='<%# Bind("ContactInfo") %>' MaxLength="100" />
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Actions" ItemStyle-Width="110px">
                            <ItemTemplate>
                                <div class="cmd">
                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="Edit" CssClass="grid-action" CausesValidation="false">Edit</asp:LinkButton>
                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="Delete" CssClass="grid-action delete"
                                        CausesValidation="false"
                                        OnClientClick="return confirm('Are you sure you want to delete this record?');">Delete</asp:LinkButton>
                                </div>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <div class="cmd">
                                    <asp:LinkButton ID="lnkUpdate" runat="server" CommandName="Update" CssClass="grid-action" CausesValidation="false">Update</asp:LinkButton>
                                    <asp:LinkButton ID="lnkCancel" runat="server" CommandName="Cancel" CssClass="grid-action" CausesValidation="false">Cancel</asp:LinkButton>
                                </div>
                            </EditItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <p class="muted" style="margin-top:16px;">
                Tip: change the status dropdown to move an item between Lost, Found and Claimed instantly.
            </p>
        </div>
    </section>

</asp:Content>
