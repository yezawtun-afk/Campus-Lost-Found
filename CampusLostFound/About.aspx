<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="CampusLostFound.About" %>

<asp:Content ID="MainContentBlock" ContentPlaceHolderID="MainContent" runat="server">

    <header class="page-header">
        <div class="container">
            <div class="page-header-crumbs">
                <a href="<%= ResolveUrl("~/Default.aspx") %>">Home</a>
                <span aria-hidden="true">/</span>
                <span>About</span>
            </div>
            <h1>One register for everything lost on campus</h1>
            <p>How the portal works, how to report an item, and what to bring when you collect it.</p>
        </div>
    </header>

    <!-- 1. Purpose -->
    <section class="chapter chapter--white">
        <div class="container intro">
            <div data-reveal>
                <h2>Fewer lost things, less wasted time</h2>
                <p class="lead">
                    Lost items used to be reported by word of mouth, by email, or not at all.
                </p>
                <p>
                    The portal puts every report in one searchable register so the owner and the
                    finder can be connected quickly. It is open to all students and staff, and no
                    account or password is needed - you only need to describe the item and leave a
                    way for the Security Office to contact you.
                </p>
                <p>
                    Every item that is handed in is stored at the Security Office in Block A until
                    it is claimed.
                </p>
            </div>

            <figure class="about-figure" data-reveal style="--reveal-delay: 90ms;">
                <img src="<%= ResolveUrl("~/Images/about.jpg") %>"
                     alt="Illustration of a lost and found box with a magnifying glass, a location pin and a checklist"
                     width="1000" height="750" />
                <figcaption>Every found item is logged, stored safely and matched with its owner.</figcaption>
            </figure>
        </div>
    </section>

    <!-- 2. How it works -->
    <section class="chapter chapter--mist">
        <div class="container">
            <div class="section-head">
                <div data-reveal>
                    <h2>From the front desk to your hands</h2>
                    <p>Four steps, reviewed by the Security Office. Nothing is released without proof of ownership.</p>
                </div>
            </div>

            <div class="grid grid-4">
                <div class="step-card" data-reveal>
                    <div class="step-card-head">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <path d="M4 20h4l10-10a3 3 0 0 0-4-4L4 16v4z"></path><path d="M13 5l6 6"></path>
                        </svg>
                        <h3>Report</h3>
                    </div>
                    <p>Describe the item, choose Lost or Found, and add a photo if you have one.</p>
                </div>

                <div class="step-card" data-reveal style="--reveal-delay: 70ms;">
                    <div class="step-card-head">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="10.5" cy="10.5" r="6.5"></circle><path d="M15.5 15.5 21 21"></path>
                        </svg>
                        <h3>Search</h3>
                    </div>
                    <p>Check the register regularly. New items are added by students and staff every day.</p>
                </div>

                <div class="step-card" data-reveal style="--reveal-delay: 140ms;">
                    <div class="step-card-head">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <path d="M12 3l7 3v6c0 5-3.5 7.6-7 9-3.5-1.4-7-4-7-9V6z"></path><path d="M9 12l2 2 4-4"></path>
                        </svg>
                        <h3>Verify</h3>
                    </div>
                    <p>Contact the office and describe the details only the owner would know.</p>
                </div>

                <div class="step-card" data-reveal style="--reveal-delay: 210ms;">
                    <div class="step-card-head">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                            <circle cx="8" cy="8" r="4"></circle><path d="M12 8h9M18 8v4M15 8v3"></path>
                        </svg>
                        <h3>Collect</h3>
                    </div>
                    <p>Bring your ID to Block A and sign for the item. The record is marked as claimed.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- 3. Reporting steps -->
    <section class="chapter chapter--white">
        <div class="container">
            <div class="section-head">
                <div data-reveal>
                    <h2>Reporting a lost or found item</h2>
                    <p>The same form is used for both. Choose the report type and the status is set automatically.</p>
                </div>
                <a class="btn btn-primary" href="<%= ResolveUrl("~/Report.aspx") %>" data-reveal>Open the report form</a>
            </div>

            <div class="grid grid-3">
                <div class="guide" data-reveal>
                    <h3>If you lost an item</h3>
                    <ol>
                        <li>Open <strong>Report Item</strong> and choose <strong>Lost</strong>.</li>
                        <li>Enter your full name and student or staff ID.</li>
                        <li>Describe the item clearly: colour, brand, size, and any marks.</li>
                        <li>Add the last place you remember having it, and the date.</li>
                        <li>Leave an email or phone number, then submit the form.</li>
                        <li>Search the register every day and watch for a matching found item.</li>
                    </ol>
                </div>

                <div class="guide" data-reveal style="--reveal-delay: 70ms;">
                    <h3>If you found an item</h3>
                    <ol>
                        <li>Hand the item in at the Security Office in Block A as soon as possible.</li>
                        <li>Open <strong>Report Item</strong> and choose <strong>Found</strong>.</li>
                        <li>Describe the item but leave out one identifying detail - it helps us verify the owner.</li>
                        <li>Record exactly where you found it and the date.</li>
                        <li>Submit the form so the owner can find it in the register.</li>
                        <li>Wait for the Security Office to match the item with its owner.</li>
                    </ol>
                </div>

                <div class="guide" data-reveal style="--reveal-delay: 140ms;">
                    <h3>If you are searching</h3>
                    <ol>
                        <li>Use <strong>Search</strong> to combine a keyword, category, location and status.</li>
                        <li>Try a shorter keyword if you get no results - "wall" also matches "Wallet".</li>
                        <li>Check both <strong>Lost</strong> and <strong>Found</strong> statuses.</li>
                        <li>Found a possible match? Note the item name and location shown on the card.</li>
                        <li>Contact the Security Office with that information.</li>
                    </ol>
                </div>
            </div>
        </div>
    </section>

    <!-- 4. Claiming guidelines -->
    <section class="chapter chapter--paper" id="guidelines">
        <div class="container">
            <div class="claim-grid">
                <div data-reveal>
                    <h2>Claiming and collection</h2>
                    <p class="lead">
                        What to bring, where to go, and how long the office keeps an item.
                    </p>
                    <ul>
                        <li>Bring your <strong>student or staff ID card</strong>. No item is released without it.</li>
                        <li>Be ready to <strong>describe identifying details</strong> that are not shown in the register.</li>
                        <li>Collect items from the <strong>Security Office, Block A, Ground Floor</strong>.</li>
                        <li>Office hours are <strong>Monday to Friday, 8:00 a.m. - 5:30 p.m.</strong></li>
                        <li>A friend may collect on your behalf only with a signed note and a copy of your ID.</li>
                        <li>Unclaimed items are kept for <strong>60 days</strong> before being donated.</li>
                    </ul>
                </div>

                <div class="hours-panel" data-reveal style="--reveal-delay: 90ms;">
                    <h3>Security Office</h3>
                    <p>Block A, Ground Floor<br />Monday to Friday<br />8:00 a.m. - 5:30 p.m.</p>
                    <p>
                        <a href="mailto:security.office@campus.edu">security.office@campus.edu</a><br />
                        <a href="tel:+10000000000">+1 (000) 000-0000</a>
                    </p>
                </div>
            </div>
        </div>
    </section>

    <!-- 5. Close -->
    <section class="chapter chapter--coral closer">
        <div class="container">
            <h2 data-reveal>Ready to report an item?</h2>
            <p data-reveal style="--reveal-delay: 80ms;">
                It takes less than two minutes, and it helps the whole campus.
            </p>
            <div class="btn-row" data-reveal>
                <a class="btn btn-ink" href="<%= ResolveUrl("~/Report.aspx?type=Lost") %>">Report lost item</a>
                <a class="btn btn-outline" href="<%= ResolveUrl("~/Report.aspx?type=Found") %>">Hand in a found item</a>
            </div>
        </div>
    </section>

</asp:Content>
