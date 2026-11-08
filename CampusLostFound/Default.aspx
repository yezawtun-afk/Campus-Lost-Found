<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CampusLostFound.Home" %>

<asp:Content ID="MainContentBlock" ContentPlaceHolderID="MainContent" runat="server">

    <!-- 1. Hero: two flat fields meeting at the waterline. -->
    <section class="hero">
        <div class="container hero-inner">
            <h1 class="hero-headline">
                <span class="hero-copy hero-copy--above" aria-hidden="true">
                    <span class="hero-line"><span>Lost Something?</span></span>
                    <span class="hero-line"><span>Let Us Help You Find It.</span></span>
                </span>
                <span class="hero-copy hero-copy--below">
                    <span class="hero-line"><span>Lost Something?</span></span>
                    <span class="hero-line"><span>Let Us Help You Find It.</span></span>
                </span>
            </h1>

            <div class="hero-foot">
                <p class="hero-lede">
                    Report what you lost, hand in what you found, or search everything
                    waiting at the campus Security Office. No account needed.
                </p>
                <div class="hero-actions">
                    <a class="btn btn-primary" href="<%= ResolveUrl("~/Report.aspx?type=Lost") %>">Report lost item</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Report.aspx?type=Found") %>">Report found item</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Items.aspx") %>">Browse items</a>
                </div>
            </div>
        </div>
    </section>

    <!-- 2. Intro: what the register is, and the numbers it holds. -->
    <section class="chapter chapter--white">
        <div class="container intro">
            <div data-reveal>
                <h2>Everything lost, one register</h2>
                <p class="lead">
                    Before this portal, lost items were reported by word of mouth, by email, or not at all.
                </p>
                <p>
                    Every report now lands in one searchable register, so the owner and the finder
                    can be connected quickly. Items handed in are stored at the Security Office in
                    Block A until they are claimed.
                </p>

                <dl class="stat-row">
                    <div class="stat">
                        <dt>Items on the register</dt>
                        <dd><asp:Literal ID="litTotal" runat="server" Text="0" /></dd>
                    </div>
                    <div class="stat">
                        <dt>Waiting to be claimed</dt>
                        <dd><asp:Literal ID="litFound" runat="server" Text="0" /></dd>
                    </div>
                    <div class="stat">
                        <dt>Returned to owners</dt>
                        <dd><asp:Literal ID="litClaimed" runat="server" Text="0" /></dd>
                    </div>
                </dl>
            </div>

            <figure class="intro-figure" data-reveal style="--reveal-delay: 90ms;">
                <img src="<%= ResolveUrl("~/Images/hero.jpg") %>"
                     alt="Illustration of a campus at dusk with a student ID card, a keyring and a location pin floating above the buildings"
                     width="1600" height="900" />
                <figcaption>Every item handed in is logged, stored safely and matched with its owner.</figcaption>
            </figure>
        </div>
    </section>

    <!-- 3. Recently reported: the field changes colour with the chosen status. -->
    <section class="chapter chapter--paper recent" id="recent" data-field="all">
        <div class="container">
            <div class="section-head">
                <div data-reveal>
                    <h2>Recently reported</h2>
                    <p>Four of the newest entries on the register. Switch the field to see what is lost, found or claimed.</p>
                </div>
                <a class="link-arrow" href="<%= ResolveUrl("~/Items.aspx") %>" data-reveal>View all items</a>
            </div>

            <div class="field-switch" role="group" aria-label="Filter these four items by status" data-field-switch>
                <a class="field-switch__btn is-active" href="<%= ResolveUrl("~/Items.aspx") %>" data-filter="">All</a>
                <a class="field-switch__btn" href="<%= ResolveUrl("~/Search.aspx?status=Lost") %>" data-filter="Lost">Lost</a>
                <a class="field-switch__btn" href="<%= ResolveUrl("~/Search.aspx?status=Found") %>" data-filter="Found">Found</a>
                <a class="field-switch__btn" href="<%= ResolveUrl("~/Search.aspx?status=Claimed") %>" data-filter="Claimed">Claimed</a>
            </div>

            <!-- Friendly error message if the database cannot be reached -->
            <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </asp:Panel>

            <asp:Repeater ID="rptRecent" runat="server">
                <HeaderTemplate><div class="grid grid-4" data-recent></HeaderTemplate>
                <ItemTemplate>
                    <article class="item-card" data-status='<%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %>' data-reveal>
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

            <p class="field-empty" data-recent-empty hidden>
                None of the four newest items is <span data-empty-label>that</span> right now.
                <a href="<%= ResolveUrl("~/Search.aspx") %>">Search the whole register</a>.
            </p>
        </div>
    </section>

    <!-- 4. How it works, on the loud field. -->
    <section class="chapter chapter--coral">
        <div class="container">
            <div class="steps-head">
                <h2 data-reveal>Three steps from lost to found</h2>
                <p data-reveal style="--reveal-delay: 80ms;">
                    No account, no queue, no paper forms. The Security Office checks every entry
                    on the register before an item is released.
                </p>
            </div>

            <div class="steps">
                <div class="step" data-reveal>
                    <h3>Report it</h3>
                    <p>Tell us what you lost, or hand in what you found. Add a photo and a contact
                       detail so the office can reach you quickly.</p>
                </div>
                <div class="step" data-reveal style="--reveal-delay: 70ms;">
                    <h3>Search the register</h3>
                    <p>Filter by name, category, location or status to see everything currently
                       held at the Security Office.</p>
                </div>
                <div class="step" data-reveal style="--reveal-delay: 140ms;">
                    <h3>Claim it in person</h3>
                    <p>Bring your student or staff ID, describe the item, and collect it from
                       Block A. It only takes a few minutes.</p>
                </div>
            </div>

            <div class="steps-cta" data-reveal>
                <a class="btn btn-ink" href="<%= ResolveUrl("~/Report.aspx") %>">Report an item</a>
            </div>
        </div>
    </section>

    <!-- 5. Close, inverted. -->
    <section class="chapter chapter--ink closer">
        <div class="container">
            <h2 data-reveal>Found something on campus?</h2>
            <p data-reveal style="--reveal-delay: 80ms;">
                Hand it in at the Security Office and log it here. The owner is probably
                searching for it right now.
            </p>
            <a class="btn btn-primary" href="<%= ResolveUrl("~/Report.aspx?type=Found") %>" data-reveal style="--reveal-delay: 140ms;">Hand in a found item</a>
        </div>
    </section>

</asp:Content>
