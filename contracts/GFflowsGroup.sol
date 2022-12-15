// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/security/ReentrancyGuard.sol";
import "OpenZeppelin/openzeppelin-contracts@4.4.1/contracts/security/Pausable.sol";
import "./GFnft.sol";

//-------------------------------------------------

/** @title GloFlow Flows Group 
    @notice Flows Group is used to group multiple flows, and control groups of people that edit and work on them.
*/
contract GFflowsGroup is Ownable, ReentrancyGuard, Pausable {

    uint16 public constant MAX_ITEMS_PER_FLOW   = 100;
    uint16 public constant MAX_EDITORS_PER_FLOW = 20;

    // max number of images that can be in a operation on a flow (add,remove)
    uint16 public constant MAX_IMAGES_PER_FLOW_OP = 10;

    // EVENTS
    event FlowCreated(address indexed creatorAddr, string indexed nameStr);
    event EditorAdded(address grantorAddr, address indexed editorAddr, string indexed flowNameStr);
    event EditorRemoved(address grantorAddr, address indexed editorAddr, string indexed flowNameStr);
    event EditorVotedForNFTcreation(address indexed editorAddr, string indexed flowNameStr);
    event ImageItemsAdded(address indexed editorAddr, string indexed flowNameStr);
    event ImageItemsRemoved(address indexed editorAddr, string indexed flowNameStr);

    // ERRORS
    error GFunauthorized();
    error GFeditorVotedForNFTcreationAlready();
    error GFeditorsVotedNotMajorityForNFTcreation();
    
    struct GFflow {
        bool      isValue;
        address   creator; 
        address[] editorsLst;
        bytes32[] itemsImgsLst;
        address[] editorsVotedForNFTcreationLst;
    }

    // Editor is a person that contributing to the flow, changing it and modifying
    struct GFflowEditor {
        uint256 creationUNIXtimeInt;
        bool    isValue;
        mapping(string=>bool) assignedFlowsMap;
    }

    
    address ownerAddr;
    string  nameStr;

    mapping(address=>GFflowEditor) internal flowsEditorsMap;
    mapping(string=>GFflow)        internal flowsMap;
    string[]                       internal flowsNamesLst;
    mapping(string=>GFnft)         internal flowsNFTsMap;

    //-------------------------------------------------
    modifier flowValidName(string memory pFlowNameStr) {
        require(bytes(pFlowNameStr).length > 0);
        _;
    }
    modifier flowExists(string memory pFlowNameStr) {
        require(flowsMap[pFlowNameStr].isValue, "flow with a given name doesnt exist");
        _;
    }
    modifier flowNotExists(string memory pFlowNameStr) {
        require(!flowsMap[pFlowNameStr].isValue, "flow with a given name doesnt exist");
        _;
    }

    // should other editors be allowed to operate on editors
    modifier canOperateOnEditors() {
        require(ownerAddr == msg.sender, "only the owner of flows group can operate on Editors");
        _;
    }

    modifier isEditorOfFlow(string memory pFlowNameStr) {
        address editorAddr = msg.sender;

        // editors are addresses in the editors lookup table and the owner of this flows_group
        require(flowsEditorsMap[editorAddr].assignedFlowsMap[pFlowNameStr] ||
            editorAddr == ownerAddr, "editor is not authorized to edit the target flow");
        _;
    }

    modifier onlyBy(address pAccountAddr) {
        if (msg.sender != pAccountAddr) revert GFunauthorized();
        _;
    }

    //-------------------------------------------------
    constructor(string memory pFlowsGroupNameStr) {
        nameStr   = pFlowsGroupNameStr;
        ownerAddr = msg.sender;
    }

    //-------------------------------------------------
    // CHANGE_OWNER
    /**
     * @notice change this flows group owner
     * @param pNewOwnerAddr address of the new owner of rhe flows group
     */
    function changeOwner(address pNewOwnerAddr)
        public
        onlyOwner {
        ownerAddr = pNewOwnerAddr;
    }
    
    //-------------------------------------------------
    // CREATE_FLOW
    
    // ADD!? - should editors be able to create flows in a flow group?
    /**
     * @notice create a particular flow. can only be done by the owner of the flows_group
     * @param pFlowNameStr name of the flow to create
     * @dev creates a new flow in the flow_group.
     */
    function createFlow(string memory pFlowNameStr)
        public
        whenNotPaused
        onlyOwner
        flowNotExists(pFlowNameStr)
        flowValidName(pFlowNameStr) {



        address flowCreatorAddr = msg.sender;
        bytes32[] memory items = new bytes32[](MAX_ITEMS_PER_FLOW);

        GFflow memory flow = GFflow({
            creator:      flowCreatorAddr,
            editorsLst:   new address[](MAX_EDITORS_PER_FLOW),
            editorsVotedForNFTcreationLst: new address[](MAX_EDITORS_PER_FLOW),
            itemsImgsLst: items,
            isValue:      true
        });

        bytes32 flowID = getFlowID(pFlowNameStr);
        flowsMap[pFlowNameStr] = flow;


        flowsNamesLst.push(pFlowNameStr);

        emit FlowCreated(flowCreatorAddr, pFlowNameStr);
    }

    //-------------------------------------------------
    // GET_ALL_FLOW_NAMES
    /**
     * @notice get a list of all flows defined in this flows_group
     * @return names of all flows in this flows_group
     */
    function getAllFlowNames() public view returns (string[] memory) {
        return flowsNamesLst;
    }

    //-------------------------------------------------
    // GET_FLOW_ID
    function getFlowID(string memory pFlowNameStr) internal returns (bytes32) {
        bytes32 flowID = keccak256(abi.encodePacked(pFlowNameStr));
        return flowID;
    }

    //-------------------------------------------------
    // EDITORS
    //-------------------------------------------------
    // ADD_EDITOR
    /**
     * @notice add editor to a particular flow
     * @param pEditorAddr address of the editor
     * @param pFlowNameStr name of the flow that the editor is being added to
     */
    function addEditor(address pEditorAddr,
        string memory pFlowNameStr)
        external
        whenNotPaused
        flowExists(pFlowNameStr)
        canOperateOnEditors {
        

        address grantorAddr = msg.sender;


        flowsMap[pFlowNameStr].editorsLst.push(pEditorAddr);

        emit EditorAdded(grantorAddr, pEditorAddr, pFlowNameStr);
    }

    //-------------------------------------------------
    // REMOVE_EDITOR
    /**
     * @notice remove editor from a particular flow
     * @param pEditorAddr address of the editor
     * @param pFlowNameStr name of the flow that the editor is being removed from
     */
    function removeEditor(address pEditorAddr,
        string memory pFlowNameStr)
        external
        whenNotPaused
        flowExists(pFlowNameStr)
        canOperateOnEditors {

        address grantorAddr = msg.sender;

        emit EditorRemoved(grantorAddr, pEditorAddr, pFlowNameStr);
    }

    //-------------------------------------------------
    // IMAGES
    //-------------------------------------------------
    // ADD_IMAGE_ITEMS_TO_FLOW
    /**
     * @notice add one or more image items to a particular flow in this group
     * @param pImagesFilesIPFScidLst list of file IPFS CIDs of images to be added to a particular flow.
     *                               generated using sha3-224 hash function and base16 encoded, so that they fit
     *                               in a bytes32 type slot.
     * @param pFlowNameStr name of the flow that the images are being added to
     */
    function addImageItemsToFlow(bytes32[] calldata pImagesFilesIPFScidLst,
        string memory pFlowNameStr)
        public
        whenNotPaused
        flowExists(pFlowNameStr)
        isEditorOfFlow(pFlowNameStr) {
        require(pImagesFilesIPFScidLst.length < MAX_IMAGES_PER_FLOW_OP);

        address editorAddr = msg.sender;

        emit ImageItemsAdded(editorAddr, pFlowNameStr);
        

    }

    //-------------------------------------------------
    // REMOVE_IMAGE_ITEMS_TO_FLOW
    /**
     * @notice remove one or more image items to a particular flow in this group.
     *         the fact that images were added will still be present in tx history.
     * @param pImagesFilesIPFScidLst list of file IPFS CIDs of images to be added to a particular flow.
     *                               generated using sha3-224 hash function and base16 encoded, so that they fit
     *                               in a bytes32 type slot.
     * @param pFlowNameStr name of the flow that the images are being added to
     */
    function remoteImageItemsFromFlow(bytes32[] calldata pImagesFilesIPFScidLst,
        string memory pFlowNameStr)
        public
        whenNotPaused
        flowExists(pFlowNameStr)
        isEditorOfFlow(pFlowNameStr) {
        require(pImagesFilesIPFScidLst.length < MAX_IMAGES_PER_FLOW_OP);

        address editorAddr = msg.sender;

        emit ImageItemsRemoved(editorAddr, pFlowNameStr);
    }

    //-------------------------------------------------
    // NFT
    //-------------------------------------------------
    // CREATE_NFT_FROM_FLOW
    /**
     * @notice create a NFT from this flow, if a majority of editors approved it
     * @param pFlowNameStr name of the flow which is to be turned into an NFT
     */
    function createNFTfromFlow(string memory pFlowNameStr,
        string memory pNFTsymbolStr) 
        public
        whenNotPaused
        onlyOwner
        flowExists(pFlowNameStr) {

        uint editorsVotedCountInt = flowsMap[pFlowNameStr].editorsVotedForNFTcreationLst.length;
        uint editorsTotalCountInt = flowsMap[pFlowNameStr].editorsLst.length;

        if (editorsTotalCountInt/2 > editorsVotedCountInt) {
            revert GFeditorsVotedNotMajorityForNFTcreation();
        }

        // create NFT
        GFnft nft = new GFnft(pNFTsymbolStr);
        flowsNFTsMap[pFlowNameStr] = nft;
    }

    //-------------------------------------------------
    // ALLOW_NFT_FROM_FLOW
    /**
     * @notice an editor is allowing for a Flow to be turned into an NFT.
     * each editor of a flow gets to allow creation of an NFT from a flow.
     * if the majority of editors of a flow allows it in can be created into an NFT.
     * @param pFlowNameStr name of the flow that the editor is being removed from
     */
    function allowNFTfromFlow(string memory pFlowNameStr)
        public
        whenNotPaused
        flowExists(pFlowNameStr)
        isEditorOfFlow(pFlowNameStr) {

        address editorVotingAddr = msg.sender;

        //-----------------
        // CHECK_EDITOR_VOTED - check if the editor already voted, and if he did reject the vote
        bool editorVotedAlreadyBool      = false;
        address[] memory editorsVotedLst = flowsMap[pFlowNameStr].editorsVotedForNFTcreationLst;
        for (uint i=0; i<editorsVotedLst.length; i++) {

            address editorWhoAlreadyVotedAddr = editorsVotedLst[i];
            if (editorWhoAlreadyVotedAddr == editorVotingAddr) {
                editorVotedAlreadyBool = true;
                break;
            }
        }
        if (editorVotedAlreadyBool) {
            revert GFeditorVotedForNFTcreationAlready();
        }

        //-----------------
        
        flowsMap[pFlowNameStr].editorsVotedForNFTcreationLst.push(editorVotingAddr);

        emit EditorVotedForNFTcreation(editorVotingAddr, pFlowNameStr);
    }

    //-------------------------------------------------
}