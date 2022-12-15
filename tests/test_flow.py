import pytest
import brownie
from brownie import GFflowsGroup, accounts

#-----------------------------------------------------------------
@pytest.fixture
def flows_group():

	test_flows_group_name_str = "test_flows"
	gf_flows_group_contract = GFflowsGroup.deploy(test_flows_group_name_str, {'from': accounts[0]})

	print(type(gf_flows_group_contract))
	return gf_flows_group_contract

#-----------------------------------------------------------------
def test_basic_ops(flows_group):


	owner_acc     = accounts[0]
	editor_01_acc = accounts[1]

	#--------------------
	# CREATE_FLOW
	flow_name_str = "test_flow_01"

	# owner of the flows_group creates a new flow
	tx = flows_group.createFlow(flow_name_str, {'from': owner_acc})


	print("=====================")

	# check that the flowCreated event got created
	# print(tx.events)
	assert "FlowCreated" in tx.events.keys()


	event = tx.events["FlowCreated"]
	
	print(event)
	print(event["creatorAddr"])
	print(event["nameStr"])
	
	# print(brownie.convert.to_string(event["nameStr"]))

	# FIX!! - figure out a decode_event solution for nameStr, to be able to compare string values

	assert "creatorAddr" in event.keys()
	assert "nameStr"     in event.keys()

	#--------------------
	# CREATE_FLOW - check exception is thrown if a non-owner user
	#               tries to create a flow.
	flow_name_2_str = "test_flow_02"
	with pytest.raises(brownie.exceptions.VirtualMachineError) as e:
		flows_group.createFlow(flow_name_str, {'from': editor_01_acc})

	#--------------------
	# check that the newly create flow is in the list of all flow names
	flows_lst = flows_group.getAllFlowNames()
	print(flows_lst)

	assert len(flows_lst) == 1
	assert flow_name_str in flows_lst

	#--------------------