<%@ Page Title="Search" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="CampusLostFound.Search" %>

<asp:Content ID="MainContentBlock" ContentPlaceHolderID="MainContent" runat="server">

    <header class="page-header page-header--mist">
        <div class="container">
            <div class="page-header-crumbs">
                <a href="<%= ResolveUrl("~/Default.aspx") %>">Home</a>
                <span aria-hidden="true">/</span>
                <span>Search</span>
            </div>
            <h1>Search the register</h1>
            <p>Combine any of the filters below. Leave a field blank to ignore it - press Enter or click Search to see results.</p>
        </div>
    </header>

    <section class="chapter chapter--mist chapter--flush-top">
        <div class="container">

            <div class="form-card" data-reveal>
                <div class="form-grid">

                    <div class="form-group span-2">
                        <label class="form-label" for="<%= txtKeyword.ClientID %>">Item name keyword</label>
                        <asp:TextBox ID="txtKeyword" runat="server" CssClass="form-control"
                            placeholder="e.g. wallet, laptop, keys" MaxLength="100" />
                        <span class="form-hint">Searches the item name. Partial words work too (for example "wall").</span>
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= ddlCategory.ClientID %>">Category</label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= ddlLocation.ClientID %>">Location</label>
                        <asp:DropDownList ID="ddlLocation" runat="server" CssClass="form-control" />
                    </div>

                    <div class="form-group">
                        <label class="form-label" for="<%= ddlStatus.ClientID %>">Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                            <asp:ListItem Value="All" Text="All statuses" />
                            <asp:ListItem Value="Lost" Text="Lost" />
                            <asp:ListItem Value="Found" Text="Found" />
                            <asp:ListItem Value="Claimed" Text="Claimed" />
                        </asp:DropDownList>
                    </div>

                    <div class="form-group form-group--end">
                        <div class="btn-row">
                            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary"
                                OnClick="btnSearch_Click" />
                            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline"
                                OnClick="btnReset_Click" CausesValidation="false" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <section class="chapter chapter--paper">
        <div class="container">

            <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </asp:Panel>

            <div class="section-head">
                <div>
                    <h2><asp:Literal ID="litCount" runat="server" /></h2>
                    <p>Results are sorted with the newest reports first.</p>
                </div>
            </div>

            <asp:Repeater ID="rptResults" runat="server">
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
                            <h3 class="item-title"><%# Eval("ItemName") %></h3>
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

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="card card-body">
                <h3>No matching items</h3>
                <p class="muted">We could not find anything with those filters. Try fewer words or a different category.</p>
                <p style="margin:0;"><a class="btn btn-outline" href="<%= ResolveUrl("~/Items.aspx") %>">Browse all items</a></p>
            </asp:Panel>

        </div>
    </section>

</asp:Content>
