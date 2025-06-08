---
layout: post
title: "The Album Exchange Story"
date: 2025-06-06 16:32:00 -0400
categories: general
tags: album-exchange music spotify
comments: true
---

During the height of Covid, a bunch of brave people gathered around a table and said, "Enough is enough!" and decided to take matters into their own hands. So they made a Discord channel to pair up random people and recommend music, and this was called Album Exchange.

That no longer exists, and Spotify's recommendation algorithm—pardon my language—sucks ass, which is why I have decided to be brave and build a website to get album recommendations.

<figure>
  <img src="/assets/images/blog/album-exchange.png" alt="Social preview for Album Exchange">
  <figcaption>Album Exchange</figcaption>
</figure>

## The Core Idea

The concept is intentionally simple:

-   I feature a weekly album pick on the homepage
-   You can submit one album recommendation per week
-   Your submission automatically becomes a playlist on my Spotify account
-   Everyone can browse the gallery of all submitted albums
-   The site shows what I'm currently listening to (when I am)

## Technical Challenges

### The Spotify API

I have never used Spotify's API before, so I had to learn to do a few things like:

1. Fetch album details for display
2. Create playlists automatically from submissions
3. Show my current listening status
4. Handle rate limits gracefully

The rate limit challenge was enjoyable. Spotify is generous with its limits, but you can hit walls quickly when fetching album art and details for every submission. I ended up implementing a caching strategy with multiple fallbacks:

```javascript
// cache album details for 24h
const albumDetailsCache = new Map();
const ALBUM_CACHE_DURATION = 24 * 60 * 60 * 1000;

// retry logic with exponential backoff
async function fetchWithRetry(fetchFn, maxRetries = MAX_RETRIES) {
	let retryDelay = INITIAL_RETRY_DELAY;

	for (let attempt = 0; attempt <= maxRetries; attempt++) {
		try {
			return await fetchFn();
		} catch (error) {
			if (error.status === 429) {
				const waitTime = error.retryAfter
					? error.retryAfter * 1000
					: retryDelay;
				await new Promise((resolve) => setTimeout(resolve, waitTime));
				retryDelay *= 2;
			}
		}
	}
}
```

### Preventing Spam

I hate when websites make me sign up. I just want people to be able to submit recommendations, but I also didn't want someone to flood the site with a 47-album playlist of "souljaboytellem.com." So, I needed a rate-limiting system without asking the users to sign up.

I went with a combination of IP address and browser fingerprinting:

```javascript
function generateSubmissionId(ip, fingerprint) {
	return crypto
		.createHash("sha256")
		.update(ip + (fingerprint || "") + (process.env.IP_SALT || ""))
		.digest("hex");
}
```

This creates a unique but anonymized identifier for each user. The salt means I can't reverse-engineer the original data, and the one-way hash means the system is privacy-friendly while preventing abuse.

The rate limit resets every Monday at midnight UTC, which gives the site a nice weekly rhythm.

### The Playlist Creation Magic

This part is my favorite. When someone submits an album, I don't just store it in a database—I create a Spotify playlist on my account with all the tracks from that album.

```javascript
export async function createAlbumPlaylist(albumId, nickname, albumName) {
	const api = await getSpotifyApi();

	// get my user profile
	const me = await api.currentUser.profile();

	// create playlist with format "nickname-album title"
	const playlistName = `${nickname}-${albumName}`.substring(0, 100);
	const playlist = await api.playlists.createPlaylist(me.id, {
		name: playlistName,
		description: `album recommendation from ${nickname} via bhav.fun`,
		public: false,
	});

	// get all tracks from the album
	const albumTracks = await api.albums.tracks(albumId);

	// add them to the playlist
	if (albumTracks.items.length > 0) {
		const trackUris = albumTracks.items.map((track) => track.uri);
		await api.playlists.addItemsToPlaylist(playlist.id, trackUris);
	}

	return playlist;
}
```

Which means every recommendation becomes an immediately playable playlist. I realize I have let the internet control my Spotify; there is a non-zero chance I wake up to my Spotify having a playlist called "Penis-Punisher." But please don't do that. I beg.

## Architecture: Next.js + Firebase + Prayers

The stack is pretty straightforward:

-   **Next.js** for the frontend and API routes
-   **Firebase Firestore** for storing submissions
-   **Spotify Web API** for everything music-related
-   **Vercel** for hosting

I organized it around clear separation of concerns:

```
├── app/                  # Next.js pages and API routes
├── components/           # React components (all the cozy UI bits)
├── lib/                  # Services and utilities
│   ├── spotify-service.js     # All Spotify API interactions
│   ├── firebase-service.js    # Database operations
│   ├── fingerprint-service.js # Rate limiting
│   └── url-utils.js           # Input validation and cleaning
```

The API design is RESTful but pragmatic. For example, the submission endpoint does the following:

1. Validate the rate limit
2. Sanitizes inputs
3. Validates Spotify URLs
4. Fetches album details
5. Create the playlist
6. Stores everything in the database

It's not the most "pure" API design, but it works well for this use case where each submission is a complex multi-step operation.

## Some Interesting Problems I Solved

### Dynamic Album Cards

I wanted album cards that could dynamically load their artwork and details from just a Spotify URL. This led to an interesting caching strategy where I cache both in-browser (localStorage) and server-side, with intelligent fallbacks when things go wrong.

### Responsive Image Handling

Album artwork comes in various sizes from Spotify, and I needed it to look good across devices. Next.js's Image component helped a lot, but I still had to handle edge cases like missing artwork:

```jsx
<Image
	src={albumImage || "/images/album-placeholder.jpg"}
	alt={`Album cover: ${albumName} by ${artistName}`}
	width={300}
	height={300}
	quality={85}
	placeholder="blur"
	blurDataURL="data:image/svg+xml,..."
	onError={onImageError}
/>
```

### The "Now Playing" Feature

I quickly realized this was slightly more nuanced than expected because Spotify's "currently playing" endpoint doesn't always have data. So I fall back to "recently played" and show that instead, with appropriate labeling. It makes the site feel more alive and personal.

## The Unexpected Joy of Building Something Small

<figure>
  <img src="/assets/images/blog/the-zen-of-python.png" alt="Zen of Python by Tim Peters">
  <figcaption>The Zen of Python</figcaption>
</figure>

One of the most rewarding aspects of this project was its scope. I built and shipped the MVP in two days, and it immediately felt proper and complete. There's something deeply satisfying about creating a tool that solves exactly one problem well.

It also forced me to make decisions quickly. Should I build user accounts? Should I add social features? Should I integrate with other music services? For now, the answer to all of these is "no," and that simplicity is part of what makes the site charming.

## Some Technical Details You Might Care About

**Security:** All user inputs are sanitized, URLs are validated to ensure they're actually Spotify links, and the rate-limiting system is designed to be privacy-friendly.

**Performance:** Album details are cached aggressively, images are optimized with Next.js's Image component, and the Spotify API calls include retry logic and error handling.

**Accessibility:** I tried to follow best practices, such as semantic HTML, proper focus management, alt text for images, and keyboard navigation support.

**SEO:** The site has proper meta tags, a sitemap, and structured data to help with discovery.

## What's Next

As sad as it is, my hyper fixation on this site has worn off, but I'm sure I will revisit this, and when I do, I'd like to make:

-   Better error handling for edge cases
-   More granular caching strategies
-   Maybe a Grand Spotify playlist that's automatically updated with all submissions

But I'm pretty happy with it as it is. Sometimes, the best software is the kind that does exactly what it says it will do without trying to be everything to everyone.

## Try It Out

You can check out [Album Exchange](https://bhav.fun/) yourself. Please submit an album you love, browse what others have recommended, or look around the source code on [GitHub](https://github.com/codebhav/album-exchange).

And if you build something similar or have ideas for improvements, [I'd love to hear about it](https://whybhav.in/contact/). The best part of sharing projects like this is the conversations they start.
