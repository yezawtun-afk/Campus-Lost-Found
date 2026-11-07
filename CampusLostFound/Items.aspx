<%@ Page Title="Lost &amp; Found Items" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Items.aspx.cs" Inherits="CampusLostFound.Items" %>

<asp:Content ID="MainContentBlock" ContentPlaceHolderID="MainContent" runat="server">

    <header class="page-header">
        <div class="container">
            <div class="page-header-crumbs">
                <a href="<%= ResolveUrl("~/Default.aspx") %>">Home</a>
                <span aria-hidden="true">/</span>
                <span>Lost &amp; Found</span>
            </div>
            <h1>Lost &amp; Found items</h1>
            <p>Every item currently recorded on campus. Filter by category, sort the list, and check where an item is being kept.</p>
        </div>
    </header>

    <section class="chapter chapter--paper">
        <div class="container">

            <!-- Category and sort controls (AutoPostBack keeps the URL in sync) -->
            <div class="toolbar">
                <div class="form-group">
                    <label for="<%= ddlCategory.ClientID %>">Category</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged" />
                </div>
                <div class="form-group">
                    <label for="<%= ddlSort.ClientID %>">Sort by</label>
                    <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-control"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                        <asp:ListItem Value="newest" Text="Newest first" />
                        <asp:ListItem Value="oldest" Text="Oldest first" />
                        <asp:ListItem Value="name" Text="Name A - Z" />
                    </asp:DropDownList>
                </div>
                <a class="link-arrow" href="<%= ResolveUrl("~/Search.aspx") %>">Advanced search</a>
                <p class="toolbar-total"><asp:Literal ID="litSummary" runat="server" /></p>
            </div>

            <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </asp:Panel>

            <asp:Repeater ID="rptItems" runat="server">
                <HeaderTemplate><div class="grid grid-3"></HeaderTemplate>
                <ItemTemplate>
                    <article class="item-card" data-reveal>
                        <div class="item-media">
                            <img src='<%# ImageUrl(Eval("ImagePath")) %>' alt='<%# Server.HtmlEncode(Convert.ToString(Eval("ItemName"))) %>'
                                 loading="lazy" onerror="this.onerror=null;this.src='Images/placeholder.jpg';" />
                            <span class='<%# StatusCss(Eval("Status")) %>'><%# Eval("Status") %></span>
                        </div>
                        <div class="item-body">
                            <span class="item-cat"><%# Eval("Category") %></span>
                            <h2 class="item-title"><%# Eval("ItemName") %></h2>
                            <p class="item-desc"><%# Eval("Description") %></p>
                            <div class="item-meta">
                                <span><%# Eval("Location") %></span>
                                <span><%# Eval("DateReported", "{0:dd MMM yyyy}") %></span>
                            </div>
                        </div>
                    </article>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>

            <!-- Shown when the current filter returns no rows -->
            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="card card-body">
                <h3>No items found</h3>
                <p class="muted">There is nothing in this category yet. Try another category, or report the item so others can help.</p>
                <p style="margin:0;"><a class="btn btn-primary" href="<%= ResolveUrl("~/Report.aspx") %>">Report an item</a></p>
            </asp:Panel>

            <asp:Literal ID="litPager" runat="server" />
        </div>
    </section>

</asp:Content>
