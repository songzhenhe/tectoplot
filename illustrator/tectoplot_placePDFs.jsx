// Illustrator script to place and embed all PDF files within a folder as
// individual layers in a new Illustrator document.

// This script should be installed into the Illustrator scripts folder and
// Illustrator should be closed and reopened.

// Example path (OSX): /Applications/Adobe Illustrator 2022/Presets.localized/en_US/Scripts/tectoplot_placePDFs.jsx

// The script can be accessed from File > Scripts > tectoplot_placePDFs


function importPDFsAsEmbeddedLayers() {
	// if a folder was selected continue with action, otherwise quit
	var myDocument;

	selectedFolder = Folder.selectDialog('Select folder containing PDF files to merge', Folder('~'))

	if (selectedFolder) {
		myDocument = app.documents.add();

		var emptyDocument = true;
		var newLayer;
		var thisPlacedItem;

		var regpdf = new RegExp('.+\.pdf$');

		// find the PDF files in the selected folder
		var pdfList = selectedFolder.getFiles(regpdf);

		// for each PDF, place it
		for (var i = 0; i < pdfList.length; i++) {
			if (pdfList[i] instanceof File) {
				if( emptyDocument ) {
					// Initialize the map document and start at the first layer
					newLayer = myDocument.layers[0];
					emptyDocument = false;
				} else {
					// Add a new layer
					newLayer = myDocument.layers.add();
				}
			   // Name the layer after the source PDF, place it and embed it
			   newLayer.name = pdfList[i].name.substring(0, pdfList[i].name.indexOf(".") );
			   thisPlacedItem = newLayer.placedItems.add()
			   thisPlacedItem.file = pdfList[i];
				 thisPlacedItem.embed();
			}
		}

		if( emptyDocument ) {
			alert("No PDF files found");
			myDocument.close();
		} else {
			myDocument.fitArtboardToSelectedArt(0)
		}
	}
}

// run
importPDFsAsEmbeddedLayers();
