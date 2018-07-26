pragma experimental ABIEncoderV2;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/ownership/NoOwner.sol';
import './Managed.sol';
import './Asset.sol';

// Needs gas opti
contract Notarizer is Ownable, Managed, Asset, NoOwner {

Template[] public templates;
Donation[] public donations;

uint256 public totalTemplates;
uint256 public totalDonations;

  struct Template {
    string description;
    uint256 goal;
    address beneficiary;
  }

  struct Donation {
    uint256 templateId;
    uint256 amount;
    address donor;
  }

  constructor() public payable {
    require(msg.value == 0);

    _createDonation("Genesis Donation", 0, address(0));
    _makeDonation(0, 0, address(0));
  }

  function batchCreateDonation(
    string[] _descriptions,
    uint256[] _goals,
    address[] _beneficiaries
  )
    onlyManagers
    public
  {
    require(_descriptions.length == _goals.length);
    require(_goals.length == _beneficiaries.length);

    for (uint i = 0; i < _descriptions.length; i++) {
      createDonation(_descriptions[i], _goals[i], _beneficiaries[i]);
    }
  }

  function createDonation(
    string _description,
    uint256 _goal,
    address _beneficiary
  )
    onlyManagers
    public
    returns (uint256)
  {
    return _createDonation(_description, _goal, _beneficiary);
  }

  function _createDonation(
    string _description,
    uint256 _goal,
    address _beneficiary
  )
    internal
    returns (uint256)
  {
    Template memory _template = Template({
      description: _description,
      goal: _goal,
      beneficiary: _beneficiary
    });

    uint256 newTemplateId = templates.push(_template);
    totalTemplates++;
    return newTemplateId;
  }

  function makeDonation(uint256 _templateId)
    public
    payable
    returns (uint256)
  {
    require(msg.value > 0);

    return _makeDonation(_templateId, msg.value, msg.sender);
  }

  function _makeDonation(uint256 _templateId, uint256 _amount, address _donor)
    internal
    returns (uint256)
  {
    Donation memory _donation = Donation({
      templateId: _templateId,
      amount: _amount,
      donor: _donor
    });

    uint256 newDonationId = donations.push(_donation);

    _mint(msg.sender, newDonationId);
    totalDonations++;
    return newDonationId;
  }
}