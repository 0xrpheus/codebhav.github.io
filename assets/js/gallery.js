document.addEventListener("DOMContentLoaded", function () {
	const modal = document.getElementById("photo-modal");
	const fullImage = document.getElementById("full-size-image");
	const closeButton = document.querySelector(".close-button");
	const photoItems = document.querySelectorAll(".photo-item");

	photoItems.forEach((item) => {
		const link = item.querySelector(".photo-link");
		link.addEventListener("click", function (e) {
			e.preventDefault();
			const fullImgSrc = item.getAttribute("data-full-img");
			fullImage.setAttribute("src", fullImgSrc);
			modal.style.display = "block";
			document.body.style.overflow = "hidden"; // prevent scrolling
		});
	});

	// close with button
	closeButton.addEventListener("click", function () {
		modal.style.display = "none";
		document.body.style.overflow = "";
	});

	// close when clicked outside of modal
	modal.addEventListener("click", function (e) {
		if (e.target === modal) {
			modal.style.display = "none";
			document.body.style.overflow = "";
		}
	});

	// close with esc key
	document.addEventListener("keydown", function (e) {
		if (e.key === "Escape" && modal.style.display === "block") {
			modal.style.display = "none";
			document.body.style.overflow = "";
		}
	});
});
