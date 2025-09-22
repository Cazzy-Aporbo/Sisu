const fetch = require('node-fetch');

async function fetchData(url) {
    try {
        const res = await fetch(url);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return await res.json();
    } catch (err) {
        console.error(`Error fetching ${url}: ${err.message}`);
        return null;
    }
}

async function aggregateData(urls) {
    const results = await Promise.all(urls.map(fetchData));
    return results.filter(r => r !== null).map(r => ({
        id: r.id,
        value: r.value * 2, // example transformation
    }));
}

(async () => {
    const data = await aggregateData([
        'https://jsonplaceholder.typicode.com/posts/1',
        'https://jsonplaceholder.typicode.com/posts/2'
    ]);
    console.log(data);
})();