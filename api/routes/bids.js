const express = require("express");
const router = express.Router();

const bidController = require("../controller/bidController");

router
  .route("/")
  .get(bidController.getAllBids)
  .post(bidController.addBids)
  .patch(bidController.updateBids)
  .delete(bidController.deleteBids);

router.route("/history").get(bidController.getBidHistory);

router.route("/suitablebids").get(bidController.locationApproriateBids);

router.route("/specific").get(bidController.getBidDetails);

router.route("/getall").get(bidController.getAllBids);

router.route("/trial").get(bidController.routeOfOrders);

module.exports = router;
