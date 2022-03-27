using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebBanMyPham.Models;
namespace WebBanMyPham.Controllers
{
    public class ThongTinGioHangController : Controller
    {
        //
        // GET: /ThongTinGioHang/

        public ActionResult Index()
        {
            return View();
        }
        public ActionResult TTGioHang(ThongTinNguoiDung us)
        {
            //if (ModelState.IsValid)
            //{
            //    Session["us"] = new ThongTinNguoiDung() { HoTen = us.HoTen, Email = us.Email, Sdt = us.Sdt };// biến session dùng chung 
            //    return RedirectToAction("TTGioHang", "ThongTinGioHang");// điều hướng sang controler home gọi dang nhập 

            //}
            return View();
           
        }

        
    }


    
}
