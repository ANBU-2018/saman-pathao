const Order = require("../models/order");
const Transporter = require("../models/transporter");
const Client = require("../models/client");
const mongoose = require("mongoose");
const mbxClient = require("@mapbox/mapbox-sdk");
const mbxMatrix = require("@mapbox/mapbox-sdk/services/matrix");
const mbxDirection = require("@mapbox/mapbox-sdk/services/directions");
const baseClient = mbxClient({
  accessToken:
    "pk.eyJ1IjoibmJobiIsImEiOiJjbDI0d3Z3ZmowMHc1M2ptbGlxcXU3M2E5In0.pNvr3Yp0jiznM1WWdkhWIA",
});
const matrixClient = mbxMatrix(baseClient);
const directionsClient = mbxDirection(baseClient);

function nearMe(order) {
  matrixClient
    .getMatrix({
      points: [
        {
          coordinates: [
            parseInt(order.startPoint[2]),
            parseInt(order.startPoint[1]),
          ],
        },
        {
          coordinates: [85.52111841641558, 27.630063957063957],
        },
      ],
      profile: "driving",
      annotations: ["distance", "duration"],
    })
    .send()
    .then((response) => {
      const matrix = response.body;
      console.log(matrix.distances, matrix.durations);
      if (matrix.distances[1] <= 1000) {
        return true;
      } else {
        return false;
      }
    })
    .catch((err) => {
      console.log(err);
      return false;
    });
}

//for transporter to add bids to suitable order
exports.addBids = async (req, res, next) => {
  // try {
  //   const checker = await Order.aggregate([
  //     {
  //       $match: {
  //         orderNo: req.body.orderNo,
  //       },
  //     },
  //     {
  //       $project: {
  //         "bids.transporter": 1,
  //         data: {
  //           $setIsSubset: [
  //             [mongoose.Types.ObjectId(req.body.transporterId)],
  //             "$bids.transporter",
  //           ],
  //         },
  //       },
  //     },
  //   ]);
  //   console.log(checker[0].bids);
  //   if (!checker[0].data) {
  //     const order = await Order.findOneAndUpdate(
  //       { orderNo: req.body.orderNo },
  //       {
  //         $push: {
  //           "bids.transporter": req.body.transporterId,
  //           "bids.bidAmount": req.body.bidAmount,
  //         },
  //       },
  //       { new: true }
  //     );
  //     await Transporter.findOneAndUpdate(
  //       { email: req.body.email },
  //       { $push: { biddedOders: order._id.toString() } }
  //     );
  //     console.log(order);
  //     res.send({ message: "bid added sucessfully" });
  //   } else {
  //     res.send({ message: "you have already bidded for this order" });
  //   }
  // } catch (err) {
  //   next(err);
  // }
  try {
    const order = await Order.findOne({ orderNo: req.body.orderNo });
    if (order) {
      var transporter = await Transporter.findOne({ email: req.body.email });
      if (transporter) {
        // console.log(order._id.toString());
        transporter.biddedOrders.push(order._id.toString());
        await transporter.save();
        order.bids.transporter.push(transporter._id.toString());
        order.bids.bidAmount.push(req.body.bidAmount);
        console.log(
          order.bidCost == 0 || order.bidCost > req.body.bidAmount,
          "from herer"
        );
        order.bidCost =
          order.bidCost == 0 || order.bidCost > req.body.bidAmount
            ? req.body.bidAmount
            : order.bidCost;
        await order.save();
        res.send(order);
      } else {
        res.send({ message: "you are not a transporter" });
      }
    } else {
      res.send({ meesage: "order not found" });
    }
  } catch (err) {
    next(err);
    // res.send(err);
  }
};

// returns all the bids on particular order of specific client
exports.getAllBids = async (req, res, next) => {
  try {
    const user = await Client.exists({
      $or: [{ userName: req.query.userName }, { email: req.query.email }],
    })
      .populate({
        path: "orders",
        select: "bids orderNo -_id",
        match: { orderNo: req.query.orderNo },
        populate: {
          path: "bids.transporter",
          select: {
            firstName: 1,
            lastName: 1,
            email: 1,
            middleName: 1,
            photo: 1,
            rating: 1,
            ratedBy: 1,
            userName: 1,
            _id: 0,
          },
        },
      })
      .sort({ "bids.bidAmount": -1 });
    if (user) {
      res.send(user);
    } else {
      res.send({ message: "you do not have this order" });
    }
  } catch (err) {
    next(err);
  }
};

// returns tranporter details for specific
exports.getBidDetails = async (req, res, next) => {
  try {
    const bidDetails = await Client.exists({
      userName: req.query.userName,
    }).populate({
      path: "orders",
      select: "orderNo -_id",
      match: { orderNo: req.query.orderNo },
      populate: {
        path: "bids.transporter",
        match: { userName: req.query.transporterUserName },
        select: {
          firstName: 1,
          lastName: 1,
          email: 1,
          middleName: 1,
          photo: 1,
          rating: 1,
          ratedBy: 1,
          userName: 1,
        },
      },
    });
    res.send(bidDetails);
  } catch (error) {
    next(error);
  }
};

// updates the bid of specific tranporter based on their userName
exports.updateBids = async (req, res, next) => {
  try {
    var i;
    const bids = await Order.findOne({ orderNo: req.body.orderNo }, "bids");
    const transporterId = await Transporter.exists({
      userName: req.body.userName,
    });
    bids.bids.transporter.forEach((element, index) => {
      if (element.toString() === transporterId._id.toString()) {
        i = index;
      }
    });
    console.log(i);

    const newBids = await Order.findOneAndUpdate(
      { orderNo: req.body.orderNo },
      { $set: { [`bids.bidAmount.${i}`]: req.body.bidAmount } },
      { new: true }
    );
    console.log(bids.bids.bidAmount[i]);
    res.send(newBids);
  } catch (error) {
    next(error);
  }
};

// used by transporter to delete bids
exports.deleteBids = async (req, res, next) => {
  try {
    var index;
    const session = await Order.startSession();
    await session.withTransaction(async () => {
      const bids = await Order.findOne({ orderNo: req.query.orderNo }, "bids ");
      var transporterTarget = await Transporter.findOne({
        _id: req.query.transporterId,
      });
      console.log(transporterTarget);
      transporterTarget.biddedOrders = transporterTarget.biddedOrders.filter(
        (item) => item.toString() !== bids._id.toString()
      );
      await transporterTarget.save();
      bids.bids.transporter.filter((element, index) => {
        if (element.toString() === req.query.transporterId) i = index;
        return element.toString() != req.query.transporterId;
      });
      bids.bids.transporter.filter((element, index) => {
        return element.toString() != req.query.transporterId;
      });
      for (var j = 0; j < bids.bids.transporter.length; j++) {
        if (bids.bids.transporter[j].toString() === req.query.transporterId) {
          index = j;
        }
      }
      bids.bids.transporter.splice(index, 1);
      bids.bids.bidAmount.splice(index, 1);
      await Order.findOneAndUpdate(
        { orderNo: req.query.orderNo },
        { $set: { bids: bids.bids } }
      );
      // console.log(bids.bids, index);
    });

    session.endSession();
    res.send({ message: "bid deleted sucessfully" });
  } catch (error) {
    next(error);
  }
};

// returns all the orders bidded by specific transporter
exports.getBidHistory = async (req, res, next) => {
  try {
    const transporter = await Transporter.exists({
      userName: req.query.userName,
    });
    // console.log(transporter._id.toString());
    // mongoose.Types.ObjectId(transporter._id.toString());
    // console.log(transporter._id);

    const order = await Order.find({
      $or: [{ orderStatus: "onbid" }, { orderStatus: "postbid" }],
      "bids.transporter": transporter._id,
    });
    res.send(order);
  } catch (err) {
    next(err);
  }
};

// returns orders that are available to bid for transporter
exports.getSuitableBids = async (req, res, next) => {
  try {
    const transporter = await Transporter.findOne({
      userName: req.query.userName,
    });
    console.log(transporter);
    const order = await Order.find({
      orderStatus: "onbid",
      "bids.transporter": {
        $ne: transporter._id.toString(),
      },
      rating: { $lte: transporter.rating },
    });
    res.send(order);
  } catch (err) {
    next(err);
  }
};

async function distanceCalculator(long1, lat1, long2, lat2) {
  var distance = await matrixClient
    .getMatrix({
      points: [
        {
          coordinates: [parseFloat(long1), parseFloat(lat1)],
        },
        {
          coordinates: [parseFloat(long2), parseFloat(lat2)],
        },
      ],
      profile: "driving",
      annotations: ["distance"],
    })
    .send()
    .then((response) => {
      const matrix = response.body;
      // console.log(matrix.distances[1][0], "from distance calculator");
      return matrix.distances[1][0];
      // if (matrix.distances[1][0] <= 6000) {
      //   suitableorder.push(order);
      //   console.log(suitableorder);
      // }
    })
    .catch((err) => {
      console.log(err);
    });
  return distance;
}

exports.locationApproriateBids = async (req, res, next) => {
  var suitableorder = [];
  const transporter = await Transporter.findOne({
    userName: req.query.userName,
  });
  selectOrder =
    "orderNo orderStatus startPoint destination distance timeFrame biddingTime maxBudget minRated fragile shipmentPhoto shipments shipmentWeight bids transporter bidCost timeLocation pickedUpTime deliveredTime";
  const result = await Order.find(
    {
      orderStatus: "onbid",
      minRated: { $lte: parseFloat(req.query.rating) },
      "bids.transporter": {
        $ne: transporter._id,
      },
    },
    selectOrder
  );
  for (var i = 0; i < result.length; i++) {
    var order = result[i];
    orderDistance = await distanceCalculator(
      order.startPoint[2],
      order.startPoint[1],
      req.query.long,
      req.query.lat
    );
    if (orderDistance <= 6000) {
      suitableorder.push(order);
    }
  }
  res.send(suitableorder);
};

exports.routeOfOrders = async (req, res, next) => {
  var directions;
  var waypoint = [];
  for (var i = 0; i < req.body.locations.length; i++) {
    waypoint[i] = {
      coordinates: [
        parseFloat(req.body.locations[i].long),
        parseFloat(req.body.locations[i].lat),
      ],
    };
  }
  console.log(waypoint);
  // res.send("hello");
  await directionsClient
    .getDirections({
      profile: "driving",
      waypoints: waypoint,
      // [
      // { coordinates: [85.33191214302876, 27.737139798885423] },
      // { coordinates: [85.5036324206804, 27.661105220208288] },
      // { coordinates: [85.24288378075327, 27.679936506793116] },
      // ],
      bannerInstructions: true,
      steps: true,
    })
    .send()
    .then((response) => {
      // directions = response.body.routes[0];
      // return directions;
      directions = response.body.routes[0].legs[0].steps.map((step) => {
        return step.maneuver.location;
      });
    });
  console.log(directions);
  res.send(directions);
};
