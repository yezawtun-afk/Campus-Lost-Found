<%@ Page Title="Something went wrong" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="CampusLostFound.ErrorPage" %>

<asp:Content ID="MainContentBlock" ContentPlaceHolderID="MainContent" runat="server">

    <section class="chapter chapter--ink error-chapter">
        <div class="container">
            <h1>Something went wrong</h1>
            <p class="lead">
                We are sorry - that page could not be loaded. Nothing you submitted has been lost.
                Please try again, or head back to the home page.
            </p>
            <p>
                If the problem continues, contact the Security Office at
                <a href="mailto:security.office@campus.edu">security.office@campus.edu</a>.
            </p>

            <div class="btn-row">
                <a class="btn btn-primary" href="<%= ResolveUrl("~/Default.aspx") %>">Back to home</a>
                <a class="btn btn-outline" href="<%= ResolveUrl("~/Items.aspx") %>">Browse items</a>
            </div>
        </div>
    </section>

</asp:Content>
