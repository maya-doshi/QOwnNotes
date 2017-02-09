import QtQml 2.0

/**
 * This script creates a menu item and a button that converts the selected Markdown
 * text to BBCode in the clipboard
 * 
 * Dependencies:
 * http://pandoc.org
 * https://github.com/2ion/pandoc-bbcode
 */
QtObject {
    /**
     * Initializes the custom action
     */
    function init() {
        script.registerCustomAction("markdownToBBCode", "Markdown to BBCode", "BBCode", "edit-copy", true);
    }

    /**
     * This function is invoked when a custom action is triggered
     * in the menu or via button
     * 
     * @param identifier string the identifier defined in registerCustomAction
     */
    function customActionInvoked(identifier) {
        if (identifier != "markdownToBBCode") {
            return;
        }

        // get the selected text from the note text edit
        var text = script.noteTextEditSelectedText();
        
        // you need pandoc and the BBCode writer from https://github.com/2ion/pandoc-bbcode
        // to convert Markdown to BBCode
        var params = ["-t", "/opt/scripts/panbbcode.lua", "-f", "markdown"];
        var result = script.startSynchronousProcess("pandoc", params, text);

        // do some code list cleanup
        result = replaceAll(result, "[list=*]", "[list]");
        result = replaceAll(result, "[/*]", "");
        
        // convert inline code blocks to italic
        // do this 10 times to take care of multiple code blocks in a line
        for (var i = 0; i < 10; i++) {
            result = result.replace(/^(.+?)\[code\](.+?)\[\/code\]/img, "$1[i]$2[/i]");
        }

        // convert headlines to bold
        result = replaceAll(result, "[h]", "[b]");
        result = replaceAll(result, "[/h]", "[/b]");

        // put the result into the clipboard
        script.setClipboardText(result);
    }
    
    function replaceAll(str, find, replace) {
        return String(str).replace(new RegExp(escapeRegExp(find), 'g'), replace);
    }
    
    function escapeRegExp(str) {
        return str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
    }
}
