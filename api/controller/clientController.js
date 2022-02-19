const bcrypt = require("bcrypt");
const Client = require("../models/client");

exports.addClient = async (req, res, next) => {
  console.log("hello from addClient 1");
  console.log(req.body);
  const hash = await bcrypt.hash(req.body.password, 10);
  req.body.password = hash;
  const userObj = req.body;
  try {
    await Client.create(userObj);
    res.send({ message: "SignUp sucessfull" });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  //   console.log("hello from login");
  try {
    const user = await Client.findOne(
      {
        $or: [{ userName: req.body.userName }, { email: req.body.email }],
      },
      "userName email photo inAppCurrency password rating idCard"
    ).populate({
      path: "orders",
      select: "orderNo biddingTime photo maxBudget bids.bidAmount",
    });
    // console.log(user);
    if (!user) {
      res.send({ message: "Email not found" });
    } else {
      const isMatch = await bcrypt.compare(req.body.password, user.password);

      if (!isMatch) {
        res.send({ message: "Password not match" });
      } else {
        const data = {
          userName: user.userName,
          email: user.email,
          photo: user.photo,
          inAppCurrency: user.inAppCurrency,
          rating: user.rating,
          idCard: user.idCard,
          orders: user.orders.map((order, index) => {
            return {
              orderNo: order.orderNo,
              biddingStartTime: order.biddingTime.start,
              biddingEndTime: order.biddingTime.end,
              biddingRemainingTime: order.biddingTime.end - Date.now(),
              photo: order.photo,
              maxBudget: order.maxBudget,
              lowestbids: Math.min(...order.bids.bidAmount),
            };
          }),
        };
        res.send({ message: "Login sucessfull", data });
      }
    }
  } catch (err) {
    next(err);
  }
};

exports.updateClient = async (req, res, next) => {
  var update = req.body;
  if (update.password) {
    update.password = await bcrypt.hash(update.password, 10);
  }
  try {
    const user = await Client.findOneAndUpdate(
      { $or: [{ email: req.body.email }, { userName: req.body.userName }] },
      update
    );
    if (!user) {
      res.send({ message: "User not found" });
    } else {
      res.send({ message: "User updated" });
    }
  } catch (err) {
    next(err);
  }
};

exports.deleteClient = async (req, res, next) => {
  try {
    const user = await Client.findOneAndDelete({
      $or: [{ userName: req.query.userName }, { email: req.query.email }],
    });
    if (!user) {
      res.send({ message: "User not found" });
    } else {
      res.send({ message: "User deleted" });
    }
  } catch (err) {
    next(err);
  }
};
