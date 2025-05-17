document.addEventListener("DOMContentLoaded", function () {
	const searchInput = document.getElementById("search-input");
	const searchResults = document.getElementById("search-results");
	let posts = [];

	fetch("/search.json")
		.then((response) => response.json())
		.then((data) => {
			posts = data;
		});

	searchInput.addEventListener("input", function () {
		const query = this.value.toLowerCase();

		if (query.length < 2) {
			searchResults.innerHTML = "";
			return;
		}

		const results = posts.filter((post) => {
			const titleMatch = post.title.toLowerCase().includes(query);
			const contentMatch = post.content.toLowerCase().includes(query);
			const tagsMatch =
				post.tags &&
				post.tags.some((tag) => tag.toLowerCase().includes(query));

			return titleMatch || contentMatch || tagsMatch;
		});

		displayResults(results);
	});

	function displayResults(results) {
		if (results.length === 0) {
			searchResults.innerHTML = "<p>No results found</p>";
			return;
		}

		let html = "<ul>";
		results.forEach((post) => {
			html += `
        <li>
          <a href="${post.url}">${post.title}</a>
          <span class="post-date">${post.date}</span>
        </li>
      `;
		});
		html += "</ul>";

		searchResults.innerHTML = html;
	}
});
