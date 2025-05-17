document.addEventListener("DOMContentLoaded", function () {
	const menuToggle = document.querySelector(".menu-toggle");
	const siteNav = document.querySelector(".site-nav ul");

	if (menuToggle) {
		menuToggle.addEventListener("click", function () {
			this.classList.toggle("active");
			siteNav.classList.toggle("active");
		});
	}
});
