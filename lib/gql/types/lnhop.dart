class LnHop {
  String chanId;
  int chanCapacity;
  int amtToForward;
  int fee;
  int expiry;
  int amtToForwardMsat;
  int feeMsat;

  LnHop(Map<String, dynamic> data) {
    chanId = data["chanId"];
    chanCapacity = data["chanCapacity"];
    amtToForward = data["amtToForward"];
    fee = data["fee"];
    expiry = data["expiry"];
    amtToForwardMsat = data["amtToForwardMsat"];
    feeMsat = data["feeMsat"];
  }
}
