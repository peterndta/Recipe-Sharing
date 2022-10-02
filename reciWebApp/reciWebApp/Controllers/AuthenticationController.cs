﻿using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using reciWebApp.Data.Models;
using Microsoft.Net.Http.Headers;
using System.Security.Claims;
using reciWebApp.Services.Interfaces;
using reciWebApp.Services;
using reciWebApp.Data.IRepositories;
using reciWebApp.Data.Repositories;
using Microsoft.AspNetCore.Http;
using reciWebApp.Services.Utils;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace reciWebApp.Controllers
{
    [Produces("application/json")]
    [Route("api/authentication")]
    [ApiController]
    public class AuthenticationController : ControllerBase
    {
        public readonly IAuthService _authService;
        public readonly IRepositoryManager _repoManager;
        public AuthenticationController(IAuthService authService, IRepositoryManager repoManager)
        {
            _authService = authService;
            _repoManager = repoManager;
        }

        [HttpGet("")]
        public IActionResult ExternalLogin()
        {
            var props = new AuthenticationProperties();
            var callback = Url.Action("ExternalLoginCallBack");
            props.RedirectUri = callback;
            return Challenge(props, "Google");
        }
       
        [HttpGet("signin-google")]
        public async Task<IActionResult> ExternalLoginCallBack()
        {
            var result = await HttpContext.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            var userLogin = _authService.GetUser(result);
            if (userLogin == null)
            {
                return Redirect($"https://recipe-sharing.vercel.app?error=invalid");
            }

            if (await _repoManager.User.GetUserAsync(userLogin.Email) == null)
            {
                userLogin.Role = "user";
                _repoManager.User.CreateUser(userLogin);
            }

            var user = await _repoManager.User.GetUserAsync(userLogin.Email);

            if (user.BanTime != null)
            {
                return Redirect($"https://recipe-sharing.vercel.app?error=inactive-user");
            }

            var accessToken = await _authService.GenerateToken(user);
            Response.Cookies.Append("jwt", accessToken, new CookieOptions
            {
                HttpOnly = true
            });
            return Redirect($"https://recipe-sharing.vercel.app/login?token={accessToken}");
        }

        [HttpPost]
        [Route("auth")]
        public async Task<IActionResult> IsAuthenticated()
        {
            try
            {
                if (Request.Headers.TryGetValue(HeaderNames.Authorization, out var headers))
                {
                    var token = headers.First();
                    var jwtToken = _authService.DecodeToken(token);

                    var emailClaim = jwtToken.Claims.FirstOrDefault(x => x.Type == "email").Value;
                    var roleClaim = jwtToken.Claims.FirstOrDefault(x => x.Type == "role").Value;

                    var userBasedEmail = await _repoManager.User.GetUserAsync(emailClaim);

                    if (userBasedEmail != null)
                    {
                        if (!userBasedEmail.Role.Equals(roleClaim))
                            return Unauthorized(new Response("You don't have permission for this request"));
                    }
                    else
                    {
                        return BadRequest(new Response("Invalid token"));
                    }

                    return Ok(new Response("", "Authorized"));
                }
                return BadRequest(new Response("Fail"));
            }
            catch (Exception ex)
            {
                return BadRequest(new Response(ex.Message));
            }
        }
    }   
}
