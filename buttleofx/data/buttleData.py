import logging
from PySide import QtCore, QtGui
# Tuttle
from pyTuttle import tuttle
# tools
from buttleofx.data import tuttleTools
# quickmamba
from quickmamba.patterns import Singleton, Signal
from quickmamba.models import QObjectListModel
# core : graph
from buttleofx.core.graph import Graph
from buttleofx.core.graph.node import Node
# gui : graphWrapper
from buttleofx.gui.graph import GraphWrapper
from buttleofx.gui.graph.node import NodeWrapper


class ButtleData(QtCore.QObject):
    """
        Class ButtleData defined by:
        - _graphWrapper
        - _graph
        - _currentNodeViewer
        - _currentNodeParam
        - _currentNodeGraph
        - _currentConnection
        - _currentCopiedNodeInfo
        - _computedImage

        This class containts all data we need to manage the application.
           
    """

    _graph = None
    _graphWrapper = None

    _currentParamNodeName = None
    _currentSelectedNodeName = None
    _currentViewerNodeName = None
    _currentConnectionId = None
    _currentCopiedNodeInfo = {}

    _mapNodeNameToComputedImage = {}
    #_tuttleImageCache = None
    _computedImage = None
    _nodeError = ""

    def init(self, view):
        self._graph = Graph()
        self._graphWrapper = GraphWrapper(self._graph, view)

        return self

    ################################################## GETTERS ET SETTERS ##################################################

    #################### getters ####################

    def getGraph(self):
        return self._graph

    def getGraphWrapper(self):
        return self._graphWrapper

    ### current data ###

    def getCurrentParamNodeName(self):
        """
            Returns the name of the current param node.
        """
        return self._currentParamNodeName

    def getCurrentSelectedNodeName(self):
        """
            Returns the name of the current selected node.
        """
        return self._currentSelectedNodeName

    def getCurrentViewerNodeName(self):
        """
            Returns the name of the current viewer node.
        """
        return self._currentViewerNodeName

    def getCurrentCopiedNodeInfo(self):
        """
            Return the list of buttle info for the current node(s) copied. 
        """
        return self._currentCopiedNodeInfo

    ### current data wrapper ###

    def getCurrentParamNodeWrapper(self):
        """
            Returns the current param nodeWrapper.
        """
        return self.getGraphWrapper().getNodeWrapper(self.getCurrentParamNodeName())

    def getCurrentSelectedNodeWrapper(self):
        """
            Returns the current selected nodeWrapper.
        """
        return self.getGraphWrapper().getNodeWrapper(self.getCurrentSelectedNodeName())

    def getCurrentViewerNodeWrapper(self):
        """
            Returns the current viewer nodeWrapper.
        """
        return self.getGraphWrapper().getNodeWrapper(self.getCurrentViewerNodeName())

    def getCurrentConnectionWrapper(self):
        """
            Returns the current currentConnectionWrapper
        """
        return self.getGraphWrapper().getConnectionWrapper(self._currentConnectionId)

    ### flag ###

    def canPaste(self):
        """
            Returns true if we can paste (= if there was at least one node selected)
        """
        return self._currentCopiedNodeInfo != {}

    #################### setters ####################

    ### current data ###

    def setCurrentParamNodeName(self, newValue):
        self._currentParamNodeName = newValue

    def setCurrentSelectedNodeName(self, newValue):
        self._currentSelectedNodeName = newValue

    def setCurrentViewerNodeName(self, newValue):
        self._currentViewerNodeName = newValue

    ### current data wrapper ###

    def setCurrentParamNodeWrapper(self, nodeWrapper):
        """
            Changes the current param node and emits the change.
        """
        if self._currentParamNodeName == nodeWrapper.getName():
            return
        self._currentParamNodeName = nodeWrapper.getName()
        self.currentParamNodeChanged.emit()

    def setCurrentSelectedNodeWrapper(self, nodeWrapper):
        """
        Changes the current selected node and emits the change.
        """
        if self._currentSelectedNodeName == nodeWrapper.getName():
            return
        self._currentSelectedNodeName = nodeWrapper.getName()
        self.currentSelectedNodeChanged.emit()

    def setCurrentViewerNodeWrapper(self, nodeWrapper):
        """
        Changes the current viewer node and emits the change.
        """
        if self._currentViewerNodeName == nodeWrapper.getName():
            return
        self._currentViewerNodeName = nodeWrapper.getName()
        self.currentViewerNodeChanged.emit()
        self.viewerChangedSignal()

    def setCurrentConnectionWrapper(self, connectionWrapper):
        """
        Changes the current conenctionWrapper and emits the change.
        """
        if self._currentConnectionId == connectionWrapper.getId():
            self._currentConnectionId = None
        else:
            self._currentConnectionId = connectionWrapper.getId()
        self.currentConnectionWrapperChanged.emit()

    ################################################## NEED TO CHANGE #####################################################

    def getNodeError(self):
        """
            Returns the name of the node that can't be displayed.
        """
        return self._nodeError

    def setNodeError(self, nodeName):
        self._nodeError = nodeName
        self.nodeErrorChanged.emit()

    def computeNode(self, frame):
        """
            Compute the node at the frame indicated
        """
        print "------- COMPUTE NODE -------"

        #Get the name of the currentNode of the viewer
        node = self.getCurrentViewerNodeName()

        #Get the output where we save the result
        self._tuttleImageCache = tuttle.MemoryCache()
        #should replace 25 by the fps of the video (a sort of getFPS(node))
        #should expose the duration of the video to the QML too
        self.getGraph().getGraphTuttle().compute(self._tuttleImageCache, node, tuttle.ComputeOptions(int(frame)))
        self._computedImage = self._tuttleImageCache.get(0)

        #Add the computedImage to the map
        self._mapNodeNameToComputedImage.update({node: self._computedImage})

        return self._computedImage

    def retrieveImage(self, frame, frameChanged):
        """
            Compute the node at the frame indicated if the frame has changed (if the time has changed)
        """
        #Get the name of the currentNode of the viewer
        node = self.getCurrentViewerNodeName()

        #Get the map
        mapNodeToImage = self._mapNodeNameToComputedImage

        try:
            self.setNodeError("")
            #If the image is already calculated
            for element in mapNodeToImage:
                if node == element and frameChanged is False:
                    print "**************************Image already calculated**********************"
                    return self._mapNodeNameToComputedImage[node]
                # If it is not
            print "************************Calcul of image***************************"
            return self.computeNode(frame)
        except Exception as e:
            print "Can't display node : " + node
            self.setNodeError(str(e))
            raise

    def updateMapAndViewer(self):
        # Clear the map
        self._mapNodeNameToComputedImage.clear()

        # Emit the signal to load the new image
        self.paramChangedSignal()

    ##################################################  #####################################################

    ##### Plugins' menu #####

    @QtCore.Slot(str, result="QVariant")
    def getQObjectPluginsIdentifiersByParentPath(self, pathname):
        """
            Returns a QObjectListModel
        """
        pluginsIds = QObjectListModel(self)
        pluginsIds.setObjectList(tuttleTools.getPluginsIdentifiersByParentPath(pathname))
        return pluginsIds

    @QtCore.Slot(str, result=bool)
    def isAPlugin(self, pluginId):
        """
            Returns if a string is a plugin identifier.
        """
        return pluginId in tuttleTools.getPluginsIdentifiers()

    ################################################## DATA EXPOSED TO QML ##################################################

    # graphWrapper
    graphWrapper = QtCore.Property(QtCore.QObject, getGraphWrapper, constant=True)

    # current param, view, and selected node
    currentParamNodeChanged = QtCore.Signal()
    currentParamNodeWrapper = QtCore.Property(QtCore.QObject, getCurrentParamNodeWrapper, setCurrentParamNodeWrapper, notify=currentParamNodeChanged)
    
    currentViewerNodeChanged = QtCore.Signal()
    currentViewerNodeWrapper = QtCore.Property(QtCore.QObject, getCurrentViewerNodeWrapper, setCurrentViewerNodeWrapper, notify=currentViewerNodeChanged)
    
    currentSelectedNodeChanged = QtCore.Signal()
    currentSelectedNodeWrapper = QtCore.Property(QtCore.QObject, getCurrentSelectedNodeWrapper, setCurrentSelectedNodeWrapper, notify=currentSelectedNodeChanged)
    
    currentConnectionWrapperChanged = QtCore.Signal()
    currentConnectionWrapper = QtCore.Property(QtCore.QObject, getCurrentConnectionWrapper, setCurrentConnectionWrapper, notify=currentConnectionWrapperChanged)

    # paste possibility ?
    pastePossibilityChanged = QtCore.Signal()
    canPaste = QtCore.Property(bool, canPaste, notify=pastePossibilityChanged)

    # error display on the Viewer
    nodeErrorChanged = QtCore.Signal()
    nodeError = QtCore.Property(str, getNodeError, setNodeError, notify=nodeErrorChanged)

    # python signals
    paramChangedSignal = Signal()
    viewerChangedSignal = Signal()


# This class exists just because thre are problems when a class extends 2 other class (Singleton and QObject)
class ButtleDataSingleton(Singleton):

    _buttleData = ButtleData()

    def get(self):
        return self._buttleData
