<header class="header dark-bg">
    <div class="toggle-nav">
        <div class="icon-reorder tooltips" data-original-title="Toggle Navigation" data-placement="bottom">
            <span class="glyphicon glyphicon-align-justify"></span>
        </div>
    </div>
    <a href="/mobileadmin" class="logo">Eezeetel <span class="lite">Mobile Admin</span></a>

    <div class="top-nav notification-row">
        <ul class="nav pull-right top-menu">
            <li class="dropdown">
                <a data-toggle="dropdown" class="dropdown-toggle" href="#">
                    <span class="glyphicon glyphicon-user"></span>
                    <span class="username"> ${userName}</span>
                    <b class="caret"></b>
                </a>
                <ul class="dropdown-menu extended logout">
                    <li class="eborder-top">
                        <a href="/masteradmin/ChangePassword.jsp">
                            <span class="glyphicon glyphicon-lock"></span> ChangePassword
                        </a>
                    </li>
                    <li>
                        <a href="/logout"><span class="glyphicon glyphicon-log-out"></span> Log Out</a>
                    </li>
                </ul>
            </li>
        </ul>
    </div>
</header>

