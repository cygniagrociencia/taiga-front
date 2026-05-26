###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

EpicsSortableDirective = ($parse, projectService) ->
    link = (scope, el, attrs) ->
        return if not projectService.hasPermission("modify_epic")

        callback = $parse(attrs.tgEpicsSortable)

        drake = dragula([el[0]], {
            copySortSource: false
            copy: false
            mirrorContainer: el[0]
            moves: (item, container, handle) ->
                return false if not $(item).is('div.epics-table-body-row')
                node = handle
                while node and node != container
                    if node.getAttribute?('svg-icon') == 'icon-draggable'
                        return true
                    cls = node.getAttribute?('class') or ''
                    if cls.indexOf('icon-draggable') >= 0
                        return true
                    node = node.parentNode
                return false
        })

        drake.on 'dragend', (item) ->
            itemEl = $(item)

            epic = itemEl.scope().epic
            newIndex = itemEl.index()

            scope.$apply () ->
                callback(scope, {epic: epic, newIndex: newIndex})

        scroll = autoScroll(window, {
            margin: 20,
            pixels: 30,
            scrollWhenOutside: true,
            autoScroll: () ->
                return this.down && drake.dragging
        })

        scope.$on "$destroy", ->
            el.off()
            drake.destroy()

    return {
        link: link
    }

EpicsSortableDirective.$inject = [
    "$parse",
    "tgProjectService"
]

angular.module("taigaComponents").directive("tgEpicsSortable", EpicsSortableDirective)
