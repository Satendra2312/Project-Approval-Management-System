import React from 'react';

const Header = () => {
    return (
        <header className="navbar navbar-dark bg-dark sticky-top flex-md-nowrap p-0 shadow">
            <a className="navbar-brand col-md-3 col-lg-2 me-0 px-3" href="/">
                <i className="bi bi-speedometer2"></i> My Dashboard
            </a>
        </header>
    );
}

export default Header;
