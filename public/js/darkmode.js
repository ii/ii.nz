function checkDarkMode() {
    var storedMode = localStorage.getItem('darkMode');
    if (storedMode === 'enabled') {
      applyDarkMode();
    }
  }

  function toggleIcon() {
    var iconElement = document.getElementById('toggleMode');
 
    if (iconElement.classList.contains('fa-moon')) {
      applyDarkMode();
      localStorage.setItem('darkMode', 'enabled');
    } else {
      removeDarkMode();
      localStorage.setItem('darkMode', 'disabled');
    }
  }

  function applyDarkMode() {
    var iconElement = document.getElementById('toggleMode');
    var bg = document.getElementById("content");
    var header = document.getElementsByTagName('header')[0];
    var navbarRight = document.getElementById('navbarRight');
    var headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6, p, b, label,li');
    var logoImage = document.getElementById('navLogo')
    var blogPosts = document.getElementsByClassName('post-list__item');
    var modals = document.getElementsByClassName('modal-content');


    iconElement.classList.remove('fa-moon');
    iconElement.classList.add('fa-sun');
    bg.classList.add('bg-dark');
    header.classList.add('header-dark');
    navbarRight.classList.add("navbar__right--dark");

    for (var i = 0; i < headings.length; i++) {
      headings[i].style.color = 'white';
    }
    for(var i = 0; i < blogPosts.length; i++){
        blogPosts[i].classList.add('blog-dark');
    }
    for(var i = 0; i < modals.length; i++){
        modals[i].classList.add('modal-dark');
    }
    logoImage.src = `{{ "assets/dark-mode-logo.png" | relURL }}`;
  }

  function removeDarkMode() {
    var iconElement = document.getElementById('toggleMode');
    var bg = document.getElementById("content");
    var header = document.getElementsByTagName('header')[0];
    var navbarRight = document.getElementById('navbarRight');
    var headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6, p, b, label,li');
    var logoImage = document.getElementById('navLogo')
    var blogPosts = document.getElementsByClassName('post-list__item');
    var modals = document.getElementsByClassName('modal-content');

    
    iconElement.classList.remove('fa-sun');
    iconElement.classList.add('fa-moon');
    bg.classList.remove('bg-dark');
    header.classList.remove('header-dark');
    navbarRight.classList.remove("navbar__right--dark");
    logoImage.src = `{{ "assets/nav-logo.png" | relURL }}`;

    for (var i = 0; i < headings.length; i++) {
      headings[i].style.color = '';
    }
    for(var i = 0; i < blogPosts.length; i++){
        blogPosts[i].classList.remove('blog-dark');
    }
    for(var i = 0; i < modals.length; i++){
        modals[i].classList.remove('modal-dark');
    }

  }