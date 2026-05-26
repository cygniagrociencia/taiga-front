###
# This source code is licensed under the terms of the
# GNU Affero General Public License found in the LICENSE file in
# the root directory of this source tree.
#
# Copyright (c) 2021-present Kaleidos INC
###

TasksSortableDirective = ($parse, projectService) ->
    link = (scope, el, attrs) ->
        return if not projectService.canEdit("modify_task")

        callback = $parse(attrs.tgTasksSortable)

        drake = dragula([el[0]], {
            copySortSource: false
            copy: false
            mirrorContainer: el[0]
            moves: (item, container, handle) ->
                return false if not $(item).is('div.single-related-task.js-related-task')
                return $(handle).closest('.task-reorder').length > 0
        })

        drake.on 'dragend', (item) ->
            itemEl = $(item)

            task = itemEl.scope().task
            newIndex = itemEl.index()

            scope.$apply () ->
                callback(scope, {task: task, newIndex: newIndex})

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

TasksSortableDirective.$inject = [
    "$parse",
    "tgProjectService"
]

angular.module("taigaComponents").directive("tgTasksSortable", TasksSortableDirective)
