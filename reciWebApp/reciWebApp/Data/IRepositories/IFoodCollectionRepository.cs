﻿using reciWebApp.Data.Models;

namespace reciWebApp.Data.IRepositories
{
    public interface IFoodCollectionRepository
    {
        void CreateFoodCollection(FoodCollection foodCollection);
    }
}