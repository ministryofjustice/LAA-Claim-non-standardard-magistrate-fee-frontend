import Decimal from 'decimal.js';

export default class CostAdjustment {
  constructor(hoursField, minutesField, costPerHourField, itemsField, costPerItemField, calculateChangeButton, adjustedCost) {
    this.hoursField = hoursField;
    this.minutesField = minutesField;
    this.costPerHourField = costPerHourField;
    this.itemsField = itemsField;
    this.costPerItemField = costPerItemField;
    this.calculateChangeButton = calculateChangeButton;
    this.adjustedCost = adjustedCost;
  }

  calculationType() {
    if (this.hoursField && this.minutesField && this.costPerHourField) {
      return 'per_hour';
    } else if (this.itemsField && this.costPerItemField) {
      return 'per_item';
    } else {
      return 'unknown_type';
    }
  }

  updateDomElements() {
    const totalPrice = this.calculateAdjustedCost();
    this.adjustedCost.innerHTML = totalPrice;
  }

  calculateAdjustedCost() {
    switch(this.calculationType()) {
      case 'per_hour':
        return this.calculateTimeCost()
      case 'per_item':
        return this.calculateItemCost()
      default:
        throw new Error('Unrecognized calculation type!');
    }
  }

  calculateTimeCost() {
    var costPerHourNum = this.convertCurrencyToNumber(this.costPerHourField?.value)
    if(isNaN(this.hoursField?.value) || isNaN(this.minutesField?.value) || isNaN(costPerHourNum)) {
      return '--';
    }

    const unitPrice = new Decimal(costPerHourNum)
    let minutes

    this.checkMinutesThreshold();

    if(this.hoursField?.value && this.minutesField?.value){
      minutes = (parseInt(this.hoursField.value) * 60) + parseInt(this.minutesField.value);
    }

    const unrounded = unitPrice.times(minutes).dividedBy(60)
    return unrounded.toFixed(2);
  }

  calculateItemCost() {
    var costPerItemNum = this.convertCurrencyToNumber(this.costPerItemField?.value)
    if(isNaN(this.itemsField?.value) || isNaN(costPerItemNum)){
      return '--';
    }

    const items = parseInt(this.itemsField?.value)
    const unitPrice = new Decimal(costPerItemNum)

    const unrounded = unitPrice.times(items);
    return unrounded.toFixed(2);
  }

  checkMinutesThreshold() {
    if(this.minutesField){
      if(parseInt(this.minutesField.value) >= 60){
        this.minutesField.value = 59;
      }
    }
  }

  convertCurrencyToNumber(string){
    return string.replace(/[^0-9.-]+/g,"")
  }
}
