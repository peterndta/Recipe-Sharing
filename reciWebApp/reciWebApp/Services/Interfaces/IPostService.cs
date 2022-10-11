﻿using reciWebApp.Data.Models;
using reciWebApp.DTOs.PostDTOs;
using reciWebApp.Services.Utils;

namespace reciWebApp.Services.Interfaces
{
    public interface IPostService
    {
        bool CheckPostAuthority(int userId, string postId);
        ShowPostDTO GetPostInfo(ShowPostDTO showPostDTO);
        IEnumerable<ShowPostDTO> SortPostByCondition(List<ShowPostDTO> posts, string? condition);
    }
}
