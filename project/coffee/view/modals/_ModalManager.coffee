AbstractView   = require '../AbstractView'
OverlayContent = require './OverlayContent'
OverlayDiagram = require './OverlayDiagram'

class ModalManager extends AbstractView

    # when new modal classes are created, add here, with reference to class name
    modals :
        overlayDiagram : classRef : OverlayDiagram, view : null
        overlayContent : classRef : OverlayContent, view : null

    isOpen : =>

        ( if @modals[name].view then return true ) for name, modal of @modals

        false

    hideOpenModal : =>

        ( if @modals[name].view then openModal = @modals[name].view ) for name, modal of @modals

        openModal?.hide()

        null

    showModal : (name, cb=null) =>
        return if @modals[name].view
        @modals[name].view = new @modals[name].classRef cb
        null

module.exports = ModalManager
