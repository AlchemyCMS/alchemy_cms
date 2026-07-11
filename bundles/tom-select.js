import TomSelect from "tom-select/dist/esm/tom-select.js"
import clear_button from "tom-select/dist/esm/plugins/clear_button/plugin.js"
import remove_button from "tom-select/dist/esm/plugins/remove_button/plugin.js"
import virtual_scroll from "tom-select/dist/esm/plugins/virtual_scroll/plugin.js"

TomSelect.define("clear_button", clear_button)
TomSelect.define("remove_button", remove_button)
TomSelect.define("virtual_scroll", virtual_scroll)

export default TomSelect
