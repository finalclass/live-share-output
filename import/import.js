const fs = require("fs");
const XmlReader = require('xml-reader');
const xmlQuery = require('xml-query');

main();

function main() {
    const dirContent = fs.readdirSync('./Text');
    const bookFiles = dirContent.filter(dir => dir.startsWith("PL-"));
    let books = {};
    
    for (const file of bookFiles) {
	const book = file.split(".")[0].split("-")[1];
	books[book] = parseFile(file);
    }

    const surql = booksToSurQL(books);
    console.log(`
OPTION IMPORT;
DEFINE ANALYZER verses_analyzer TOKENIZERS blank FILTERS lowercase,ascii;
DEFINE TABLE bible SCHEMALESS PERMISSIONS NONE;
DEFINE INDEX verses_search ON TABLE bible COLUMNS verse SEARCH ANALYZER verses_analyzer BM25 HIGHLIGHTS;
BEGIN TRANSACTION;
${surql}
COMMIT TRANSACTION;`
   );
}

function booksToSurQL(books) {
    const sqlStmt = [];

    forEachVerse(books, (book, chapter, no, verse) => {
	sqlStmt.push(
	    `UPDATE bible:[${book},${chapter},${no}] CONTENT { verse: "${verse}" };`
	);
    });

    return sqlStmt.join("\n");
}

function forEachVerse(books, fn) {
    for (const [book, chapters] of Object.entries(books)) {
	for (const [chapter, verses] of Object.entries(chapters)) {
	    for (const [no, verse] of Object.entries(verses)) {
		fn(book, chapter, no, verse);
	    }
	}
    }
}

function findVersesP(parent) {
    const wordSection1 = parent.children.find(node => node.attributes.class === "WordSection1");
    if (wordSection1) {
	parent = wordSection1;
    }
    const p = parent.children.filter(node => node.name === "p");
    return p.filter(n => (
	n.attributes.class === "BibleIndent" 
	    || n.attributes.class === "BibleIndentCxSpMiddle")
		    && n.attributes.id
		   );
}

function parseFile(file) {
    const xml = fs.readFileSync('./Text/' + file, 'utf8');
    const ast = XmlReader.parseSync(xml);
    const body = ast.children.find(node => node.name === "body");
    const versesP = findVersesP(body);
    const verses = {};

    for (const p of versesP) {
	const addr = p.attributes.id.split("-")[1];
	const [ch, v] = addr.split("_");
	let txt = ""
	
	for (const child of p.children) {
	    if  (child.type === "element"  && child.name === "i")  {
		txt += "_" + child.children[0].value + "_";
	    }

	    if (child.type !== "text") {
		continue;
	    }

	    txt += child.value.replaceAll("&nbsp;", " ");
	}

	if (!verses[ch]) {
	    verses[ch] = {};
	}

	verses[ch][v] = txt;
    }

    return verses
}
